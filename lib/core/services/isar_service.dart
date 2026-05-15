import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/note_model.dart';
import '../../models/user_model.dart';

/// A web-compatible local cache using shared_preferences.
/// Replaces Isar which is native-only (Android/iOS/Desktop).
class IsarService {
  static const _notesKey = 'cached_notes';
  static const _userKey = 'cached_user';

  Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_notesKey, encoded);
  }

  Future<List<NoteModel>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_notesKey);
      if (raw == null) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => NoteModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['id'] == id) return UserModel.fromJson(map);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
