import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchProfile(session.user.id);
    } else {
      state = state.copyWith(isLoading: false);
    }

    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _fetchProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState(user: null);
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    debugPrint("Fetching profile for user: $userId");
    try {
      final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      
      if (data != null) {
        debugPrint("Profile found: Name: ${data['name']}, Uni ID: ${data['uni_id']}");
        state = state.copyWith(user: UserModel.fromJson(data), isLoading: false, error: null);
      } else {
        debugPrint("Profile missing for $userId, attempting self-healing...");
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final newProfile = {
            'id': user.id,
            'email': user.email,
            'name': user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
            'semester': '1',
            'role': 'student',
          };
          await _supabase.from('users').upsert(newProfile);
          debugPrint("Self-healing successful for ${user.id}");
          state = state.copyWith(user: UserModel.fromJson(newProfile), isLoading: false, error: null);
        } else {
          debugPrint("Self-healing failed: No current auth user");
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      debugPrint("Error in _fetchProfile: $e");
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> signUp(String name, String? email, String password, String role, String? uniId, String semester) async {
    if ((email == null || email.isEmpty) && (uniId == null || uniId.isEmpty)) {
      throw Exception('Please provide either an Email or a University ID.');
    }

    state = state.copyWith(isLoading: true);
    try {
      // Use uni_id as placeholder email if email is missing
      final registrationEmail = (email != null && email.isNotEmpty) 
          ? email 
          : '${uniId!.replaceAll(' ', '')}@smartnotes.internal';

      final AuthResponse res = await _supabase.auth.signUp(
        email: registrationEmail,
        password: password,
        data: {'name': name},
      );

      final user = res.user;
      if (user != null) {
        try {
          await _supabase.from('users').upsert({
            'id': user.id,
            'name': name,
            'email': (email != null && email.isNotEmpty) ? email : null,
            'uni_id': (uniId != null && uniId.isNotEmpty) ? uniId : null,
            'role': role,
            'semester': semester,
          });
        } catch (insertError) {
          if (insertError is PostgrestException && insertError.code == '23505') {
             throw Exception('University ID or Email already exists.');
          }
          throw Exception('Auth succeeded, but profile creation failed: $insertError');
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String friendlyError = 'Signup failed: $e';
      
      if (e is AuthException) {
        if (e.statusCode == '500' || e.message.contains('Database error saving new user')) {
          friendlyError = 'Database Error (500): Check your Supabase database triggers or users table schema.';
        } else {
          friendlyError = e.message;
        }
      } else if (e is PostgrestException) {
        if (e.code == '23505') {
          friendlyError = 'University ID or Email already in use.';
        } else {
          friendlyError = e.message;
        }
      } else if (e is Exception) {
         friendlyError = e.toString().replaceAll('Exception: ', '');
      }

      state = state.copyWith(error: friendlyError, isLoading: false);
      throw Exception(friendlyError);
    }
  }

  Future<void> updateProfile({required String name, required String semester, String? email, String? uniId}) async {
    final userId = state.user?.id;
    if (userId == null) return;

    debugPrint("Updating profile for user: $userId");
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('users').update({
        'name': name,
        'semester': semester,
        'email': (email != null && email.isNotEmpty) ? email : null,
        'uni_id': (uniId != null && uniId.isNotEmpty) ? uniId : null,
      }).eq('id', userId);
      
      debugPrint("Update successful, refreshing profile...");
      await _fetchProfile(userId);
    } catch (e) {
      debugPrint("Error in updateProfile: $e");
      String friendlyError = e.toString();
      if (e is PostgrestException && e.code == '23505') {
        friendlyError = 'University ID or Email already in use by another student.';
      }
      state = state.copyWith(error: friendlyError, isLoading: false);
      throw Exception(friendlyError);
    }
  }

  Future<void> updateProfileImage(String path, Uint8List bytes) async {
    final userId = state.user?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      // Upload to 'profile_images' bucket
      await _supabase.storage.from('profile_images').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final String imageUrl = _supabase.storage.from('profile_images').getPublicUrl(path);

      // Update user table
      await _supabase.from('users').update({'profile_image_url': imageUrl}).eq('id', userId);
      
      await _fetchProfile(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
