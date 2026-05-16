import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

class AdminState {
  final List<UserModel> allUsers;
  final List<NoteModel> allNotes;
  final List<Map<String, dynamic>> auditLogs;
  final List<Map<String, dynamic>> subjects;
  final bool isMaintenanceMode;
  final int totalNotes;
  final int totalAssignments;
  final bool isLoading;

  AdminState({
    this.allUsers = const [],
    this.allNotes = const [],
    this.auditLogs = const [],
    this.subjects = const [],
    this.isMaintenanceMode = false,
    this.totalNotes = 0,
    this.totalAssignments = 0,
    this.isLoading = false,
  });

  AdminState copyWith({
    List<UserModel>? allUsers,
    List<NoteModel>? allNotes,
    List<Map<String, dynamic>>? auditLogs,
    List<Map<String, dynamic>>? subjects,
    bool? isMaintenanceMode,
    int? totalNotes,
    int? totalAssignments,
    bool? isLoading,
  }) {
    return AdminState(
      allUsers: allUsers ?? this.allUsers,
      allNotes: allNotes ?? this.allNotes,
      auditLogs: auditLogs ?? this.auditLogs,
      subjects: subjects ?? this.subjects,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      totalNotes: totalNotes ?? this.totalNotes,
      totalAssignments: totalAssignments ?? this.totalAssignments,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get studentCount => allUsers.where((u) => u.role == 'student').length;
  int get teacherCount => allUsers.where((u) => u.role == 'teacher').length;
  int get adminCount => allUsers.where((u) => u.role == 'admin').length;
}

class AdminNotifier extends StateNotifier<AdminState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminNotifier() : super(AdminState()) {
    _init();
  }

  Future<void> _init() async {
    await fetchAllUsers();
    await fetchSystemStats();
    await fetchAuditLogs();
    await fetchSubjects();
    await fetchMaintenanceMode();
  }

  Future<void> fetchSubjects() async {
    try {
      final data = await _supabase.from('subjects').select().order('semester', ascending: true);
      state = state.copyWith(subjects: List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> addSubject(String name, int semester) async {
    await _supabase.from('subjects').insert({'name': name, 'semester': semester});
    await _logAction('ADD_SUBJECT', null, 'Added subject $name for Semester $semester');
    await fetchSubjects();
  }

  Future<void> deleteSubject(String id, String name) async {
    await _supabase.from('subjects').delete().eq('id', id);
    await _logAction('DELETE_SUBJECT', id, 'Deleted subject $name');
    await fetchSubjects();
  }

  Future<void> fetchMaintenanceMode() async {
    try {
      final data = await _supabase.from('app_config').select().eq('key', 'maintenance_mode').single();
      state = state.copyWith(isMaintenanceMode: data['value'].toString() == 'true');
    } catch (e) {
      // Ignore
    }
  }

  Future<void> toggleMaintenanceMode(bool value) async {
    await _supabase.from('app_config').upsert({'key': 'maintenance_mode', 'value': value.toString()});
    await _logAction('TOGGLE_MAINTENANCE', null, 'Maintenance mode set to $value');
    state = state.copyWith(isMaintenanceMode: value);
  }

  Future<void> fetchAuditLogs() async {
    try {
      final data = await _supabase
          .from('audit_logs')
          .select('*, admin:users!audit_logs_admin_id_fkey(name)')
          .order('created_at', ascending: false)
          .limit(50);
      state = state.copyWith(auditLogs: List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _logAction(String action, String? targetId, String details) async {
    try {
      final adminId = _supabase.auth.currentUser?.id;
      await _supabase.from('audit_logs').insert({
        'admin_id': adminId,
        'action': action,
        'target_id': targetId,
        'details': details,
      });
      await fetchAuditLogs();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchAllUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabase.from('users').select().order('created_at', ascending: false);
      final users = (data as List).map((e) => UserModel.fromJson(e)).toList();
      state = state.copyWith(allUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchSystemStats() async {
    try {
      final notes = await _supabase.from('notes').select('id');
      final assignments = await _supabase.from('assignments').select('id');
      state = state.copyWith(
        totalNotes: (notes as List).length,
        totalAssignments: (assignments as List).length,
      );
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchAllNotes() async {
    try {
      final data = await _supabase.from('notes').select().order('created_at', ascending: false);
      final notes = (data as List).map((e) => NoteModel.fromJson(e)).toList();
      state = state.copyWith(allNotes: notes);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _supabase.from('users').update({'role': newRole}).eq('id', userId);
    await _logAction('UPDATE_ROLE', userId, 'Changed role to $newRole');
    await fetchAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _supabase.from('users').delete().eq('id', userId);
    await _logAction('DELETE_USER', userId, 'User deleted');
    await fetchAllUsers();
  }

  Future<void> updateNoteStatus(String noteId, String status) async {
    await _supabase.from('notes').update({'status': status}).eq('id', noteId);
    await _logAction('MODERATE_NOTE', noteId, 'Note status set to $status');
    await fetchAllNotes();
  }

  Future<String> exportData() async {
    try {
      final users = await _supabase.from('users').select();
      final notes = await _supabase.from('notes').select();
      final data = {
        'backup_date': DateTime.now().toIso8601String(),
        'users': users,
        'notes': notes,
      };
      await _logAction('BACKUP_DATA', null, 'System data backup performed');
      return data.toString();
    } catch (e) {
      return "Export failed: $e";
    }
  }
}
