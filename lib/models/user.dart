enum UserRole {
  client,
  agent, // maps to SALON on the backend
  admin,
}

class User {
  final String id;
  final String? email;
  final String? phone;
  final String? firstname;
  final String? lastname;
  final UserRole role;

  const User({
    required this.id,
    required this.role,
    this.email,
    this.phone,
    this.firstname,
    this.lastname,
  });

  String get displayName {
    final parts = [firstname, lastname].where((p) => p != null && p.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return email ?? phone ?? id;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      role: _roleFromString(json['role'] as String? ?? 'CLIENT'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstname': firstname,
      'lastname': lastname,
      'role': _roleToBackend(role),
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value.toUpperCase()) {
      case 'SALON':
        return UserRole.agent;
      case 'ADMIN':
        return UserRole.admin;
      case 'CLIENT':
      default:
        return UserRole.client;
    }
  }

  static String _roleToBackend(UserRole role) {
    switch (role) {
      case UserRole.agent:
        return 'SALON';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.client:
        return 'CLIENT';
    }
  }
}
