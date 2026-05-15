import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String contentUrl;
  @HiveField(4)
  final String? category;
  @HiveField(5)
  final List<String> tags;
  @HiveField(6)
  final bool isShared;
  @HiveField(7)
  final int viewCount;
  @HiveField(8)
  final String authorId;
  @HiveField(9)
  final String authorName;
  @HiveField(10)
  final String status;
  @HiveField(11)
  final String? semester;
  @HiveField(12)
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    this.description,
    required this.contentUrl,
    this.category,
    this.tags = const [],
    this.isShared = false,
    this.viewCount = 0,
    required this.authorId,
    required this.authorName,
    required this.status,
    this.semester,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      contentUrl: json['content_url'] ?? '',
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      isShared: json['is_shared'] ?? false,
      viewCount: json['view_count'] ?? 0,
      authorId: json['author_id'],
      authorName: json['users'] != null ? json['users']['name'] : 'Unknown Author',
      status: json['status'] ?? 'pending',
      semester: json['semester'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content_url': contentUrl,
      'category': category,
      'tags': tags,
      'is_shared': isShared,
      'view_count': viewCount,
      'author_id': authorId,
      'author_name': authorName,
      'status': status,
      'semester': semester,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
