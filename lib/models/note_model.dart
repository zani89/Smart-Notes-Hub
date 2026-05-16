import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String uploaderId;
  @HiveField(4)
  final String semester;
  @HiveField(5)
  final String course;
  @HiveField(6)
  final String status;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final String uploaderName;
  @HiveField(9)
  final String? contentUrl;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.contentUrl,
    required this.uploaderId,
    required this.semester,
    required this.course,
    required this.status,
    required this.createdAt,
    this.uploaderName = 'Unknown',
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? '',
      contentUrl: json['content_url'],
      uploaderId: json['uploader_id'] ?? 'system',
      semester: json['semester']?.toString() ?? '1',
      course: json['course'] ?? 'General',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      uploaderName: json['uploader'] != null ? json['uploader']['name'] : 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'content_url': contentUrl,
      'uploader_id': uploaderId,
      'semester': semester,
      'course': course,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
