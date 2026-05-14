class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String? createdBy;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    this.createdBy,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      location: json['location'],
      createdBy: json['created_by'],
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? targetRole;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.targetRole,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      targetRole: json['target_role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ContributionRequestModel {
  final String id;
  final String noteId;
  final String studentId;
  final String? reason;
  final String status;

  ContributionRequestModel({
    required this.id,
    required this.noteId,
    required this.studentId,
    this.reason,
    required this.status,
  });

  factory ContributionRequestModel.fromJson(Map<String, dynamic> json) {
    return ContributionRequestModel(
      id: json['id'],
      noteId: json['note_id'],
      studentId: json['student_id'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
    );
  }
}
