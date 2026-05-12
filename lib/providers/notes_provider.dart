import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box _notesBox = Hive.box('notesBox');

  List<NoteModel> _notes = [];
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  NotesProvider() {
    _loadFromLocal();
    _fetchFromSupabase();
    _subscribeToRealtime();
  }

  void _loadFromLocal() {
    final storedNotes = _notesBox.get('all_notes');
    if (storedNotes != null) {
      List<dynamic> decoded = jsonDecode(storedNotes);
      _notes = decoded.map((e) => NoteModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _fetchFromSupabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase.from('notes').select().order('created_at', ascending: false);
      _notes = (data as List<dynamic>).map((e) => NoteModel.fromJson(e)).toList();
      
      // Save to local cache
      _notesBox.put('all_notes', jsonEncode(data));
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _subscribeToRealtime() {
    try {
      _supabase.from('notes').stream(primaryKey: ['id']).listen((data) {
        _notes = data.map((e) => NoteModel.fromJson(e)).toList();
        // Update local cache
        _notesBox.put('all_notes', jsonEncode(data));
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Realtime subscription error (probably offline or invalid keys): $e");
    }
  }

  Future<void> uploadNote({
    required String title,
    required String description,
    required String category,
    required String filePath,
    required String fileName,
    required String authorId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Upload to Supabase Storage
      final String fullPath = '$authorId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      // We assume filePath is valid and points to a file, handled by file_picker in UI
      // For cross-platform support with file_picker, if on web, we would use bytes.
      // But for windows/android, we can use file upload. Since we are generic here,
      // let's assume UI handles upload directly if we pass bytes, but here we expect the UI 
      // to do the actual Storage upload and just pass the URL, or we do it here.
      // We will actually let UI pass the file data, but let's keep this signature and 
      // we can adapt it if needed.
      
      // Placeholder for storage upload:
      // final fileBytes = File(filePath).readAsBytesSync();
      // await _supabase.storage.from('notes_files').uploadBinary(fullPath, fileBytes);
      // final publicUrl = _supabase.storage.from('notes_files').getPublicUrl(fullPath);

      final String dummyUrl = 'https://example.com/$fullPath'; // REPLACE THIS in real implementation

      // 2. Insert into database
      await _supabase.from('notes').insert({
        'title': title,
        'description': description,
        'category': category,
        'content_url': dummyUrl,
        'author_id': authorId,
      });

      // Stream will auto-update the list
    } catch (e) {
      debugPrint("Error uploading note: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNoteStatus(String noteId, String newStatus) async {
    try {
      await _supabase.from('notes').update({'status': newStatus}).eq('id', noteId);
      // Stream will auto-update the list
    } catch (e) {
      debugPrint("Error updating note status: $e");
      rethrow;
    }
  }

  List<NoteModel> get approvedNotes => _notes.where((n) => n.status == 'approved').toList();
  List<NoteModel> get pendingNotes => _notes.where((n) => n.status == 'pending').toList();
  List<NoteModel> getNotesByAuthor(String authorId) => _notes.where((n) => n.authorId == authorId).toList();
}
