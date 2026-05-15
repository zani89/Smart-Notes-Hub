import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/university_models.dart';

final universityProvider = StateNotifierProvider<UniversityNotifier, UniversityState>((ref) {
  return UniversityNotifier();
});

class UniversityState {
  final List<EventModel> events;
  final List<NotificationModel> notifications;
  final List<ContributionRequestModel> contributionRequests;
  final bool isLoading;

  UniversityState({
    this.events = const [],
    this.notifications = const [],
    this.contributionRequests = const [],
    this.isLoading = false,
  });

  UniversityState copyWith({
    List<EventModel>? events,
    List<NotificationModel>? notifications,
    List<ContributionRequestModel>? contributionRequests,
    bool? isLoading,
  }) {
    return UniversityState(
      events: events ?? this.events,
      notifications: notifications ?? this.notifications,
      contributionRequests: contributionRequests ?? this.contributionRequests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UniversityNotifier extends StateNotifier<UniversityState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  UniversityNotifier() : super(UniversityState()) {
    fetchEvents();
    fetchNotifications();
  }

  Future<void> fetchEvents() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _supabase.from('events').select().order('event_date', ascending: true);
      final events = (data as List).map((e) => EventModel.fromJson(e)).toList();
      state = state.copyWith(events: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await _supabase.from('notifications').select().order('created_at', ascending: false);
      final notifications = (data as List).map((e) => NotificationModel.fromJson(e)).toList();
      state = state.copyWith(notifications: notifications);
    } catch (e) {
      // Silently ignore
    }
  }

  Future<void> createEvent(String title, String desc, DateTime date, String loc, String userId) async {
    await _supabase.from('events').insert({
      'title': title,
      'description': desc,
      'event_date': date.toIso8601String(),
      'location': loc,
      'created_by': userId,
    });
    fetchEvents();
  }

  Future<void> createNotification(String title, String message, String? role, String userId) async {
    await _supabase.from('notifications').insert({
      'title': title,
      'message': message,
      'target_role': role,
      'created_by': userId,
    });
    fetchNotifications();
  }
}
