class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? department;
  final bool? mustChangePassword;
  final String? createdBy;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.department,
    this.mustChangePassword,
    this.createdBy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString(),
      role: json['role']?.toString(),
      department: json['department']?.toString(),
      mustChangePassword: json['must_change_password'] as bool?,
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'department': department,
      'must_change_password': mustChangePassword,
      'created_by': createdBy,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? department,
    bool? mustChangePassword,
    String? createdBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
