import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/university_models.dart';

class UniversityProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<EventModel> _events = [];
  List<NotificationModel> _notifications = [];
  List<ContributionRequestModel> _contributionRequests = [];
  bool _isLoading = false;

  List<EventModel> get events => _events;
  List<NotificationModel> get notifications => _notifications;
  List<ContributionRequestModel> get contributionRequests => _contributionRequests;
  bool get isLoading => _isLoading;

  UniversityProvider() {
    fetchEvents();
    fetchNotifications();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase.from('events').select().order('event_date', ascending: true);
      _events = (data as List).map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase.from('notifications').select().order('created_at', ascending: false);
      _notifications = (data as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> fetchContributionRequests() async {
    try {
      final data = await _supabase.from('contribution_requests').select();
      _contributionRequests = (data as List).map((e) => ContributionRequestModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _supabase.from('contribution_requests').update({'status': status}).eq('id', requestId);
    fetchContributionRequests();
  }
}
