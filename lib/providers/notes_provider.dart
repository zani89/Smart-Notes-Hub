import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../core/services/storage_service.dart';
import '../core/constants/course_constants.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier();
});

class NotesState {
  final List<NoteModel> notes;
  final List<String> favorites;
  final List<String> recents;
  final bool isLoading;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedSemester;

  NotesState({
    this.notes = const [],
    this.favorites = const [],
    this.recents = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedSemester,
  });

  NotesState copyWith({
    List<NoteModel>? notes,
    List<String>? favorites,
    List<String>? recents,
    bool? isLoading,
    String? searchQuery,
    String? selectedCategory,
    String? selectedSemester,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      favorites: favorites ?? this.favorites,
      recents: recents ?? this.recents,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSemester: selectedSemester ?? this.selectedSemester,
    );
  }

  List<NoteModel> get filteredNotes {
    return notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.semester.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.course.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == null || note.course == selectedCategory;
      final matchesSemester = selectedSemester == null || note.semester == selectedSemester;
      return matchesSearch && matchesCategory && matchesSemester;
    }).toList();
  }

  bool isFavorite(String noteId) => favorites.contains(noteId);
}

class NotesNotifier extends StateNotifier<NotesState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final Box<NoteModel> _notesBox;

  NotesNotifier() : super(NotesState()) {
    _notesBox = Hive.box<NoteModel>('notesBox');
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await fetchNotes();
    await fetchFavorites(); // Added this
    _subscribeToRealtime();
  }

  Future<void> fetchFavorites() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase.from('favorites').select('note_id').eq('user_id', userId);
      final favIds = (data as List).map((f) => f['note_id'] as String).toList();
      state = state.copyWith(favorites: favIds);
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    }
  }

  // ... (keeping fetchFavorites and toggleFavorite)

  Future<void> _loadFromLocal() async {
    final localNotes = _notesBox.values.toList();
    // Sort by createdAt descending
    localNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(notes: localNotes);
  }

  Future<void> fetchNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      // Explicitly name the relationship with an alias to ensure clear mapping in the model
      final data = await _supabase.from('notes')
          .select('*, uploader:users!notes_uploader_id_fkey(name)')
          .order('created_at', ascending: false);
      
      final fetchedNotes = (data as List<dynamic>).map((e) {
        try {
          return NoteModel.fromJson(e);
        } catch (err) {
          debugPrint("Error parsing note: $err \n Data: $e");
          return null;
        }
      }).whereType<NoteModel>().toList();
      
      state = state.copyWith(notes: fetchedNotes, isLoading: false);
      
      // Sync to Hive
      await _notesBox.clear();
      await _notesBox.addAll(fetchedNotes);
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  void _subscribeToRealtime() {
    _supabase.from('notes').stream(primaryKey: ['id']).listen((data) {
      fetchNotes();
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSemester(String? semester) {
    String? newCategory = state.selectedCategory;
    if (semester != null) {
      final courses = semesterCourses[semester] ?? [];
      if (newCategory != null && !courses.contains(newCategory)) {
        newCategory = null;
      }
    }
    state = state.copyWith(selectedSemester: semester, selectedCategory: newCategory);
  }

  Future<void> toggleFavorite(String noteId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final isFav = state.favorites.contains(noteId);
    final newFavs = List<String>.from(state.favorites);

    try {
      if (isFav) {
        newFavs.remove(noteId);
        await _supabase.from('favorites').delete().eq('user_id', userId).eq('note_id', noteId);
      } else {
        newFavs.add(noteId);
        await _supabase.from('favorites').insert({'user_id': userId, 'note_id': noteId});
      }
      state = state.copyWith(favorites: newFavs);
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }

  void addToRecents(String noteId) {
    final newRecents = List<String>.from(state.recents);
    newRecents.remove(noteId);
    newRecents.insert(0, noteId);
    if (newRecents.length > 10) newRecents.removeLast();
    state = state.copyWith(recents: newRecents);
  }

  Future<void> incrementViewCount(String noteId) async {
    // viewCount removed from NoteModel for now
  }

  Future<void> uploadNote({
    required String title,
    required String content,
    required String course,
    required String semester,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      if (title.isEmpty || content.isEmpty || course.isEmpty || semester.isEmpty) {
        throw Exception('All fields are required');
      }

      String? contentUrl;
      if (fileBytes != null && fileName != null) {
        final path = '${_supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        contentUrl = await StorageService.uploadFile(
          bucket: 'notes_files',
          path: path,
          bytes: fileBytes,
        );
      }

      await _supabase.from('notes').insert({
        'title': title,
        'content': content,
        'content_url': contentUrl,
        'course': course,
        'uploader_id': _supabase.auth.currentUser!.id,
        'status': 'pending',
        'semester': semester,
      });

      await fetchNotes();
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateNoteContent(String noteId, String newContent) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('notes').update({'content': newContent}).eq('id', noteId);
      await fetchNotes();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateNoteStatus(String noteId, String status) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('notes').update({'status': status}).eq('id', noteId);
      await fetchNotes();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> batchUpdateNoteStatus(List<String> noteIds, String status) async {
    if (noteIds.isEmpty) return;
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('notes').update({'status': status}).filter('id', 'in', noteIds);
      await fetchNotes();
    } catch (e) {
      debugPrint("Error in batch update: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
