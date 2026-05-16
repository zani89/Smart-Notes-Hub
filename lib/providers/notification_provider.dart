import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;

  NotificationState({this.notifications = const [], this.isLoading = false});

  NotificationState copyWith({List<AppNotification>? notifications, bool? isLoading}) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final _supabase = Supabase.instance.client;

  NotificationNotifier() : super(NotificationState()) {
    _init();
  }

  void _init() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Listen for note status changes (approvals)
    _supabase.from('notes').stream(primaryKey: ['id']).eq('uploader_id', userId).listen((data) {
      for (var row in data) {
        if (row['status'] == 'approved') {
          _addNotification('Note Approved!', 'Your note "${row['title']}" has been approved by a teacher.');
        }
      }
    });

    // Listen for new assignments
    _supabase.from('assignments').stream(primaryKey: ['id']).listen((data) {
      if (data.isNotEmpty) {
        final last = data.last;
        _addNotification('New Assignment', 'A new assignment "${last['title']}" has been posted.');
      }
    });

    // Listen for collaboration requests on own notes
    _supabase.from('contribution_requests').stream(primaryKey: ['id']).listen((data) async {
      for (var row in data) {
        if (row['status'] == 'pending') {
          // Check if this note belongs to the current user
          final noteData = await _supabase.from('notes').select('uploader_id, title').eq('id', row['note_id']).maybeSingle();
          if (noteData != null && noteData['uploader_id'] == userId) {
             _addNotification('Collab Request', 'Someone wants to collaborate on "${noteData['title']}"');
          }
        }
      }
    });
  }

  void _addNotification(String title, String message) {
    final newNotif = AppNotification(
      id: DateTime.now().toIso8601String(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(notifications: [newNotif, ...state.notifications]);
  }

  void markAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications.map((n) => n.id == id ? AppNotification(id: n.id, title: n.title, message: n.message, createdAt: n.createdAt, isRead: true) : n).toList(),
    );
  }
}
