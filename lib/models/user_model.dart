class UserModel {
  final String id;
  final String name;
  final String email;
  final String uniId;
  final String role;
  final String semester;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.uniId,
    required this.role,
    required this.semester,
  });

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      uniId: json['uni_id'] ?? '',
      role: json['role'] ?? 'student',
      semester: json['semester'] ?? '',
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
    };
  }
}
