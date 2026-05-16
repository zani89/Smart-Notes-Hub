import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collaboration_model.dart';
import '../models/note_model.dart';

final collaborationProvider = StateNotifierProvider<CollaborationNotifier, CollaborationState>((ref) {
  return CollaborationNotifier();
});

class CollaborationState {
  final List<NoteModel> sharedNotes;
  final List<ContributionRequestModel> requests;
  final Set<String> acceptedNoteIds;
  final bool isLoading;

  CollaborationState({
    this.sharedNotes = const [],
    this.requests = const [],
    this.acceptedNoteIds = const {},
    this.isLoading = false,
  });

  CollaborationState copyWith({
    List<NoteModel>? sharedNotes,
    List<ContributionRequestModel>? requests,
    Set<String>? acceptedNoteIds,
    bool? isLoading,
  }) {
    return CollaborationState(
      sharedNotes: sharedNotes ?? this.sharedNotes,
      requests: requests ?? this.requests,
      acceptedNoteIds: acceptedNoteIds ?? this.acceptedNoteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  CollaborationNotifier() : super(CollaborationState()) {
    fetchSharedNotes();
    fetchRequests();
  }

  Future<void> fetchSharedNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabase.from('notes')
          .select('*, users!notes_uploader_id_fkey(name)')
          .inFilter('status', ['approved', 'requested_collab'])
          .order('created_at', ascending: false);
      final notes = (data as List<dynamic>).map((e) => NoteModel.fromJson(e)).toList();
      state = state.copyWith(sharedNotes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchRequests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase.from('contribution_requests')
          .select('*, notes(title, course), handled_by_user:users!contribution_requests_handled_by_fkey(name)')
          .eq('student_id', userId)
          .order('created_at', ascending: false);
      
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data);
      final reqs = list.map((e) => ContributionRequestModel.fromJson(e)).toList();
      
      // Track IDs of notes that the student is authorized to edit
      final acceptedIds = reqs
          .where((r) => r.status == 'accepted')
          .map((r) => r.noteId)
          .toSet();
          
      state = state.copyWith(requests: reqs, acceptedNoteIds: acceptedIds);
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
  }

  Future<void> requestContribution(String noteId, String reason) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('contribution_requests').insert({
        'note_id': noteId,
        'student_id': userId,
        'reason': reason,
        'status': 'pending',
      });
      await fetchRequests();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.from('contribution_requests').update({'status': status}).eq('id', requestId);
      await fetchRequests();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
