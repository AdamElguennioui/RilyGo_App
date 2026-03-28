enum UserRole {
  client,
  agent,
}

class User {
  final String id;
  final String phone;
  final UserRole role;

  const User({
    required this.id,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: _roleFromString(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'role': role.name,
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'agent':
        return UserRole.agent;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}