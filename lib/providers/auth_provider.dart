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
    try {
      final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      if (data != null) {
        state = state.copyWith(user: UserModel.fromJson(data), isLoading: false);
      } else {
        // Fallback or self-healing
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
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

  Future<void> signUp(String name, String email, String password, String role, String uniId, String semester) async {
    state = state.copyWith(isLoading: true);
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        try {
          await _supabase.from('users').insert({
            'id': user.id,
            'name': name,
            'email': email,
            'uni_id': uniId,
            'role': role,
            'semester': semester,
          });
        } catch (insertError) {
          // Attempt to clean up the auth user if profile creation fails
          // (Requires admin privileges or a secure edge function usually, but we'll try)
          // For now, throw a descriptive error.
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
          friendlyError = 'Database Error (500): Check your Supabase database triggers or users table schema. Supabase failed to save the new user internally.';
        } else {
          friendlyError = e.message;
        }
      } else if (e is PostgrestException) {
        if (e.code == '23505') {
          friendlyError = 'University ID already in use.';
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

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
