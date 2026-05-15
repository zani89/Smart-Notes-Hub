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
  final bool isLoading;

  CollaborationState({
    this.sharedNotes = const [],
    this.requests = const [],
    this.isLoading = false,
  });

  CollaborationState copyWith({
    List<NoteModel>? sharedNotes,
    List<ContributionRequestModel>? requests,
    bool? isLoading,
  }) {
    return CollaborationState(
      sharedNotes: sharedNotes ?? this.sharedNotes,
      requests: requests ?? this.requests,
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
          .select('*, users!notes_author_id_fkey(name)')
          .eq('is_shared', true)
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
          .select()
          .eq('student_id', userId)
          .order('created_at', ascending: false);
      final reqs = (data as List<dynamic>).map((e) => ContributionRequestModel.fromJson(e)).toList();
      state = state.copyWith(requests: reqs);
    } catch (e) {
      // Ignore
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
}
