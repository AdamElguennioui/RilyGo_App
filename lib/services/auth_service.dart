import '../data/local/local_storage_service.dart';
import '../data/remote/api_client.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _currentUser = LocalStorageService().loadUser();
  }

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient().post('/auth/sign-in', {
      'email': email,
      'password': password,
    });

    final token = data['access_token'] as String?
        ?? data['token'] as String?
        ?? data['accessToken'] as String?;
    if (token != null) {
      await LocalStorageService().saveToken(token);
    }

    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    final user = User.fromJson(userJson);
    _currentUser = user;
    await LocalStorageService().saveUser(user);
    return user;
  }

  Future<User> signUp({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
    String? phone,
    UserRole role = UserRole.client,
  }) async {
    final data = await ApiClient().post('/auth/sign-up', {
      'email': email,
      'password': password,
      'firstname': ?firstname,
      'lastname': ?lastname,
      'phone': ?phone,
      'role': role == UserRole.agent ? 'SALON' : 'CLIENT',
    });

    final token = data['access_token'] as String?
        ?? data['token'] as String?
        ?? data['accessToken'] as String?;
    if (token != null) {
      await LocalStorageService().saveToken(token);
    }

    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    final user = User.fromJson(userJson);
    _currentUser = user;
    await LocalStorageService().saveUser(user);
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await LocalStorageService().clearSession();
  }
}
