import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

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
          await _fetchUserProfile(session.user.id);
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("Auth init error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final data = await _supabase.from('users').select().eq('id', userId).single();
      _currentUser = UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password, String role) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'role': role,
        });
        await _fetchUserProfile(response.user!.id);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
