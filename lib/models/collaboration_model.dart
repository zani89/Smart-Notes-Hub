import 'package:hive/hive.dart';

part 'collaboration_model.g.dart';

@HiveType(typeId: 3)
class ContributionRequestModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String noteId;
  @HiveField(2)
  final String studentId;
  @HiveField(3)
  final String? reason;
  @HiveField(4)
  final String status; // 'pending', 'accepted', 'denied'
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final String? noteTitle;
  @HiveField(7)
  final String? noteCourse;
  @HiveField(8)
  final String? studentName;
  @HiveField(9)
  final String? handledByName;

  ContributionRequestModel({
    required this.id,
    required this.noteId,
    required this.studentId,
    this.reason,
    required this.status,
    required this.createdAt,
    this.noteTitle,
    this.noteCourse,
    this.studentName,
    this.handledByName,
  });

  factory ContributionRequestModel.fromJson(Map<String, dynamic> json) {
    return ContributionRequestModel(
      id: json['id'],
      noteId: json['note_id'],
      studentId: json['student_id'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      noteTitle: json['notes'] != null ? json['notes']['title'] : null,
      noteCourse: json['notes'] != null ? json['notes']['course'] : null,
      studentName: json['users'] != null ? json['users']['name'] : null,
      handledByName: json['handled_by_user'] != null ? json['handled_by_user']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note_id': noteId,
      'student_id': studentId,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
