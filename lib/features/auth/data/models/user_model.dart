/// User Model - Represents a user/account in the app
/// Like a TypeScript interface but with methods to convert to/from database format
class UserModel {
  final int? id;
  final String name;
  final String password; // Hashed password
  final String? email;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.name,
    required this.password,
    this.email,
    required this.createdAt,
    this.isActive = true,
  });

  /// Creates a User from database row (Map)
  /// Like: const user = { id: 1, name: "John" } in JS
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      password: map['password'] as String,
      email: map['email'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  /// Converts User to database format (Map)
  /// Like: JSON.stringify(user) in JS
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'password': password,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Creates a copy with some fields changed
  /// Like: { ...user, name: "New Name" } in JS
  UserModel copyWith({
    int? id,
    String? name,
    String? password,
    String? email,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Returns user data without password (for display purposes)
  /// Like: const { password, ...userData } = user in JS
  Map<String, dynamic> toMapWithoutPassword() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, isActive: $isActive)';
  }
}
