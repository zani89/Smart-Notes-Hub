class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? uniId;
  final String role;
  final String semester;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.uniId,
    required this.role,
    required this.semester,
    this.profileImageUrl,
  });

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'],
      uniId: json['uni_id'],
      role: json['role'] ?? 'student',
      semester: json['semester'] ?? '1',
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'uni_id': uniId,
      'role': role,
      'semester': semester,
      'profile_image_url': profileImageUrl,
    };
  }
}
