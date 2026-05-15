import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

@HiveType(typeId: 1)
class AssignmentModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String teacherId;
  @HiveField(4)
  final DateTime dueDate;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final String? course; // Optional field if we add it later

  AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.teacherId,
    required this.dueDate,
    required this.createdAt,
    this.course,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      teacherId: json['teacher_id'],
      dueDate: DateTime.parse(json['due_date']),
      createdAt: DateTime.parse(json['created_at']),
      course: json['course'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacher_id': teacherId,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'course': course,
    };
  }
}

@HiveType(typeId: 2)
class SubmissionModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String assignmentId;
  @HiveField(2)
  final String studentId;
  @HiveField(3)
  final String fileUrl;
  @HiveField(4)
  final String? grade;
  @HiveField(5)
  final String? feedback;
  @HiveField(6)
  final DateTime createdAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
    this.grade,
    this.feedback,
    required this.createdAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      fileUrl: json['file_url'],
      grade: json['grade'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      'grade': grade,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
