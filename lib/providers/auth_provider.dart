import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  
  // Smart authentication check
  bool get isAuthenticated => _supabase.auth.currentSession != null;
  bool get hasProfile => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _fetchUserProfile(session.user.id);
      }
      
      _supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          _isLoading = true;
          notifyListeners();
          await _fetchUserProfile(session.user.id);
          _isLoading = false;
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("Auth init error: $e");
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      // Retry logic for profile creation (Supabase triggers take a few ms)
      int retries = 0;
      dynamic data;
      
      while (retries < 3) {
        data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
        if (data != null) break;
        
        debugPrint("Profile not found, retrying... ($retries)");
        await Future.delayed(const Duration(milliseconds: 800));
        retries++;
      }
      
      if (data != null) {
        _currentUser = UserModel.fromJson(data);
      } else {
        // Self-healing: manual insert if trigger failed
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final metadata = user.userMetadata ?? {};
          await _supabase.from('users').insert({
            'id': userId,
            'name': metadata['name'] ?? 'User',
            'email': user.email,
            'role': metadata['role'] ?? 'student',
          });
          final newData = await _supabase.from('users').select().eq('id', userId).single();
          _currentUser = UserModel.fromJson(newData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
