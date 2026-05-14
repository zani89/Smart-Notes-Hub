class NoteModel {
  final String id;
  final String title;
  final String? description;
  final String contentUrl;
  final String? category;
  final List<String> tags;
  final bool isShared;
  final int viewCount;
  final String authorId;
  final String authorName; // Added author name
  final String status;
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
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      contentUrl: json['content_url'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      isShared: json['is_shared'] ?? false,
      viewCount: json['view_count'] ?? 0,
      authorId: json['author_id'],
      authorName: json['users'] != null ? json['users']['name'] : 'Unknown Author',
      status: json['status'] ?? 'pending',
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
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
