import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

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
          (note.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (note.semester?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          note.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory = selectedCategory == null || note.category == selectedCategory;
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
    _subscribeToRealtime();
  }

  Future<void> _loadFromLocal() async {
    final localNotes = _notesBox.values.toList();
    // Sort by createdAt descending
    localNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(notes: localNotes);
  }

  Future<void> fetchNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabase.from('notes').select('*, users!notes_author_id_fkey(name)').order('created_at', ascending: false);
      final fetchedNotes = (data as List<dynamic>).map((e) => NoteModel.fromJson(e)).toList();
      
      state = state.copyWith(notes: fetchedNotes, isLoading: false);
      
      // Sync to Hive
      await _notesBox.clear();
      await _notesBox.addAll(fetchedNotes);
    } catch (e) {
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
    state = state.copyWith(selectedSemester: semester);
  }

  void toggleFavorite(String noteId) {
    final newFavs = List<String>.from(state.favorites);
    if (newFavs.contains(noteId)) {
      newFavs.remove(noteId);
    } else {
      newFavs.add(noteId);
    }
    state = state.copyWith(favorites: newFavs);
  }

  void addToRecents(String noteId) {
    final newRecents = List<String>.from(state.recents);
    newRecents.remove(noteId);
    newRecents.insert(0, noteId);
    if (newRecents.length > 10) newRecents.removeLast();
    state = state.copyWith(recents: newRecents);
  }

  Future<void> incrementViewCount(String noteId) async {
    try {
      final note = state.notes.firstWhere((n) => n.id == noteId);
      await _supabase.from('notes').update({'view_count': note.viewCount + 1}).eq('id', noteId);
    } catch (e) {
      // Ignore
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
    String? semester,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final storagePath = 'notes/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage.from('notes_files').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

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
        'semester': semester,
      });

      await fetchNotes();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateNoteStatus(String noteId, String status) async {
    await _supabase.from('notes').update({'status': status}).eq('id', noteId);
    await fetchNotes();
  }
}
