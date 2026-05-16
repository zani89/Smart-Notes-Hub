import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/assignment_model.dart';
import '../core/services/storage_service.dart';

final assignmentsProvider = StateNotifierProvider<AssignmentsNotifier, AssignmentsState>((ref) {
  return AssignmentsNotifier();
});

class AssignmentsState {
  final List<AssignmentModel> assignments;
  final List<SubmissionModel> submissions;
  final bool isLoading;

  AssignmentsState({
    this.assignments = const [],
    this.submissions = const [],
    this.isLoading = false,
  });

  AssignmentsState copyWith({
    List<AssignmentModel>? assignments,
    List<SubmissionModel>? submissions,
    bool? isLoading,
  }) {
    return AssignmentsState(
      assignments: assignments ?? this.assignments,
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<AssignmentModel> get pendingAssignments {
    final submittedIds = submissions.map((s) => s.assignmentId).toSet();
    return assignments.where((a) => !submittedIds.contains(a.id)).toList();
  }

  List<AssignmentModel> get submittedAssignments {
    final submittedIds = submissions.map((s) => s.assignmentId).toSet();
    return assignments.where((a) => submittedIds.contains(a.id)).toList();
  }
}

class AssignmentsNotifier extends StateNotifier<AssignmentsState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final Box<AssignmentModel> _assignmentsBox;

  AssignmentsNotifier() : super(AssignmentsState()) {
    _assignmentsBox = Hive.box<AssignmentModel>('assignmentsBox');
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await fetchAssignments();
    await fetchSubmissions();
  }

  Future<void> _loadFromLocal() async {
    final localAssignments = _assignmentsBox.values.toList();
    localAssignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    state = state.copyWith(assignments: localAssignments);
  }

  Future<void> fetchAssignments() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabase.from('assignments').select().order('due_date', ascending: true);
      final fetchedAssignments = (data as List<dynamic>).map((e) => AssignmentModel.fromJson(e)).toList();
      
      state = state.copyWith(assignments: fetchedAssignments, isLoading: false);
      
      // Sync to Hive
      await _assignmentsBox.clear();
      await _assignmentsBox.addAll(fetchedAssignments);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchSubmissions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase.from('submissions').select().eq('student_id', userId);
      final fetchedSubmissions = (data as List<dynamic>).map((e) => SubmissionModel.fromJson(e)).toList();
      state = state.copyWith(submissions: fetchedSubmissions);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> uploadAndSubmit(String assignmentId, String fileName, Uint8List fileBytes) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final path = '$assignmentId/${userId}_$fileName';
      final fileUrl = await StorageService.uploadFile(
        bucket: 'submissions',
        path: path,
        bytes: fileBytes,
      );

      await _supabase.from('submissions').insert({
        'assignment_id': assignmentId,
        'student_id': userId,
        'file_url': fileUrl,
      });
      await fetchSubmissions();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
