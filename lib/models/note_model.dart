class NoteModel {
  final String id;
  final String title;
  final String? description;
  final String contentUrl;
  final String? category;
  final String authorId;
  final String status;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    this.description,
    required this.contentUrl,
    this.category,
    required this.authorId,
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
      authorId: json['author_id'],
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
      'author_id': authorId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
