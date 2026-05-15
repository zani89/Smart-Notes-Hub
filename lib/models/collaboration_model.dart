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

  ContributionRequestModel({
    required this.id,
    required this.noteId,
    required this.studentId,
    this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ContributionRequestModel.fromJson(Map<String, dynamic> json) {
    return ContributionRequestModel(
      id: json['id'],
      noteId: json['note_id'],
      studentId: json['student_id'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
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
