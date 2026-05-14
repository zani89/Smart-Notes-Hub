import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box _notesBox = Hive.box('notesBox');
  final Box _prefsBox = Hive.box('prefsBox');

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  NotesProvider() {
    _loadFromCache();
    _fetchFromSupabase();
    _subscribeToRealtime();
  }

  void _loadFromCache() {
    final cached = _notesBox.get('all_notes');
    if (cached != null) {
      final List<dynamic> decoded = jsonDecode(cached);
      _notes = decoded.map((e) => NoteModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _fetchFromSupabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase.from('notes').select('*, users(name)').order('created_at', ascending: false);
      _notes = (data as List<dynamic>).map((e) => NoteModel.fromJson(e)).toList();
      _notesBox.put('all_notes', jsonEncode(data));
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _subscribeToRealtime() {
    _supabase.from('notes').stream(primaryKey: ['id']).listen((data) async {
      await _fetchFromSupabase();
    });
  }

  // --- Search & Filter ---

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<NoteModel> get filteredNotes {
    return _notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(_searchQuery) ||
          (note.description?.toLowerCase().contains(_searchQuery) ?? false) ||
          note.tags.any((t) => t.toLowerCase().contains(_searchQuery));
      final matchesCategory = _selectedCategory == null || note.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<NoteModel> get approvedNotes => filteredNotes.where((n) => n.status == 'approved').toList();
  List<NoteModel> get pendingNotes => _notes.where((n) => n.status == 'pending').toList();
  List<NoteModel> get sharedNotes => filteredNotes.where((n) => n.isShared).toList();

  // --- Favorites & Recents ---

  List<NoteModel> get favoriteNotes {
    final List<String> favIds = List<String>.from(_prefsBox.get('favorites', defaultValue: <String>[]));
    return _notes.where((n) => favIds.contains(n.id)).toList();
  }

  bool isFavorite(String noteId) {
    final List<String> favIds = List<String>.from(_prefsBox.get('favorites', defaultValue: <String>[]));
    return favIds.contains(noteId);
  }

  void toggleFavorite(String noteId) {
    final List<String> favIds = List<String>.from(_prefsBox.get('favorites', defaultValue: <String>[]));
    if (favIds.contains(noteId)) {
      favIds.remove(noteId);
    } else {
      favIds.add(noteId);
    }
    _prefsBox.put('favorites', favIds);
    notifyListeners();
  }

  void addToRecents(String noteId) {
    final List<String> recentIds = List<String>.from(_prefsBox.get('recents', defaultValue: <String>[]));
    recentIds.remove(noteId);
    recentIds.insert(0, noteId);
    if (recentIds.length > 10) recentIds.removeLast();
    _prefsBox.put('recents', recentIds);
    notifyListeners();
  }

  // --- Actions ---

  Future<void> updateNoteStatus(String noteId, String status) async {
    try {
      await _supabase.from('notes').update({'status': status}).eq('id', noteId);
      await _fetchFromSupabase();
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> uploadNote({
    required String title,
    required String description,
    required String category,
    required List<String> tags,
    required String filePath,
    required String fileName,
    required bool isShared,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // In a real app, you would upload the file here
      // This is a simulation using a dummy URL for the demo
      final storagePath = 'notes/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final fileUrl = _supabase.storage.from('notes_files').getPublicUrl(storagePath);

      await _supabase.from('notes').insert({
        'title': title,
        'description': description,
        'category': category,
        'tags': tags,
        'content_url': fileUrl,
        'is_shared': isShared,
        'author_id': _supabase.auth.currentUser!.id,
        'status': 'pending',
      });

      await _fetchFromSupabase();
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementViewCount(String noteId) async {
    try {
      final note = _notes.firstWhere((n) => n.id == noteId);
      await _supabase.from('notes').update({'view_count': note.viewCount + 1}).eq('id', noteId);
    } catch (e) {
      debugPrint('Error incrementing view: $e');
    }
  }

  // --- Analytics ---

  Map<String, dynamic> getAnalytics() {
    if (_notes.isEmpty) return {'total': 0, 'approved': 0, 'pending': 0, 'rate': '0%'};
    final total = _notes.length;
    final approved = _notes.where((n) => n.status == 'approved').length;
    final pending = _notes.where((n) => n.status == 'pending').length;
    final rate = '${((approved / total) * 100).toStringAsFixed(1)}%';
    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rate': rate,
    };
  }
}
