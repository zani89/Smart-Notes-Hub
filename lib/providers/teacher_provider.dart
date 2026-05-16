import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';
import '../models/collaboration_model.dart';

final teacherProvider = StateNotifierProvider<TeacherNotifier, TeacherState>((ref) {
  return TeacherNotifier();
});

class TeacherState {
  final int studentCount;
  final int courseCount;
  final int pendingNotesCount;
  final List<AssignmentModel> assignments;
  final List<SubmissionModel> allSubmissions;
  final List<ContributionRequestModel> contributionRequests;
  final bool isLoading;

  TeacherState({
    this.studentCount = 0,
    this.courseCount = 0,
    this.pendingNotesCount = 0,
    this.assignments = const [],
    this.allSubmissions = const [],
    this.contributionRequests = const [],
    this.isLoading = false,
  });

  TeacherState copyWith({
    int? studentCount,
    int? courseCount,
    int? pendingNotesCount,
    List<AssignmentModel>? assignments,
    List<SubmissionModel>? allSubmissions,
    List<ContributionRequestModel>? contributionRequests,
    bool? isLoading,
  }) {
    return TeacherState(
      studentCount: studentCount ?? this.studentCount,
      courseCount: courseCount ?? this.courseCount,
      pendingNotesCount: pendingNotesCount ?? this.pendingNotesCount,
      assignments: assignments ?? this.assignments,
      allSubmissions: allSubmissions ?? this.allSubmissions,
      contributionRequests: contributionRequests ?? this.contributionRequests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  TeacherNotifier() : super(TeacherState()) {
    fetchDashboardStats();
    fetchTeacherAssignments();
    fetchContributionRequests();
  }

  Future<void> fetchDashboardStats() async {
    state = state.copyWith(isLoading: true);
    try {
      // Student count
      final students = await _supabase.from('users').select('id').eq('role', 'student');
      final studentCount = (students as List).length;

      // Distinct courses from notes
      final courses = await _supabase.from('notes').select('course');
      final uniqueCourses = (courses as List).map((e) => e['course']).toSet();

      // Pending notes
      final pending = await _supabase.from('notes').select('id').eq('status', 'pending');
      final pendingCount = (pending as List).length;

      // Pending collab requests
      final pendingCollab = await _supabase.from('contribution_requests').select('id').eq('status', 'pending');
      final pendingCollabCount = (pendingCollab as List).length;

      state = state.copyWith(
        studentCount: studentCount,
        courseCount: uniqueCourses.length,
        pendingNotesCount: pendingCount + pendingCollabCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchTeacherAssignments() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase.from('assignments').select().eq('teacher_id', userId).order('due_date', ascending: true);
      final assignments = (data as List).map((e) => AssignmentModel.fromJson(e)).toList();
      state = state.copyWith(assignments: assignments);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('assignments').insert({
      'title': title,
      'description': description,
      'teacher_id': userId,
      'due_date': dueDate.toIso8601String(),
    });
    await fetchTeacherAssignments();
  }

  Future<void> fetchAllSubmissions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get all assignments by this teacher, then their submissions
      final assignments = await _supabase.from('assignments').select('id').eq('teacher_id', userId);
      final assignmentIds = (assignments as List).map((a) => a['id'] as String).toList();

      if (assignmentIds.isEmpty) {
        state = state.copyWith(allSubmissions: []);
        return;
      }

      final subs = await _supabase.from('submissions').select().inFilter('assignment_id', assignmentIds);
      final submissions = (subs as List).map((e) => SubmissionModel.fromJson(e)).toList();
      state = state.copyWith(allSubmissions: submissions);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> gradeSubmission(String submissionId, String grade, String feedback) async {
    await _supabase.from('submissions').update({
      'grade': grade,
      'feedback': feedback,
    }).eq('id', submissionId);
    await fetchAllSubmissions();
  }

  Future<void> fetchContributionRequests() async {
    try {
      final data = await _supabase.from('contribution_requests')
          .select('*, users!contribution_requests_student_id_fkey(name), notes(title)')
          .order('created_at', ascending: false);
      
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data);
      state = state.copyWith(contributionRequests: list.map((e) {
        return ContributionRequestModel.fromJson(e);
      }).toList());
    } catch (e) {
      // Ignore
    }
  }

  Future<void> updateContributionRequestStatus(String requestId, String status) async {
    final teacherId = _supabase.auth.currentUser?.id;
    await _supabase.from('contribution_requests').update({
      'status': status,
      'handled_by': teacherId,
    }).eq('id', requestId);
    await fetchContributionRequests();
  }
}
