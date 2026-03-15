import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? _currentUser;
  String? _lastSentOtp;
  String? _lastPhoneNumber;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));

    _lastPhoneNumber = phone;
    _lastSentOtp = '1234';
  }

  Future<User> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_lastPhoneNumber != phone) {
      throw Exception('Aucun OTP envoyé pour ce numéro.');
    }

    if (_lastSentOtp == null) {
      throw Exception('OTP introuvable.');
    }

    if (otp != _lastSentOtp) {
      throw Exception('Code OTP incorrect.');
    }

    final user = _buildFakeUser(phone);
    _currentUser = user;

    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  User _buildFakeUser(String phone) {
    final cleanedPhone = phone.trim();

    final role = cleanedPhone.endsWith('1')
        ? UserRole.agent
        : UserRole.client;

    return User(
      id: role == UserRole.agent ? 'agent_1' : 'client_1',
      phone: cleanedPhone,
      role: role,
    );
  }
}