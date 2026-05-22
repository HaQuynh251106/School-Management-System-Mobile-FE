import '../../../core/storage/token_storage.dart';
import 'auth_api.dart';
import 'models/user_model.dart';

class AuthRepository {
  AuthRepository({required this.api, required this.storage});

  final AuthApi api;
  final TokenStorage storage;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final data = await api.login(username: username, password: password);
    await storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> tryRestoreSession() async {
    final token = await storage.getAccessToken();
    if (token == null) return null;
    try {
      return await api.getMe();
    } catch (_) {
      await storage.clearAll();
      return null;
    }
  }

  Future<void> forgotPassword(String email) => api.forgotPassword(email);

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {}
    await storage.clearAll();
  }
}
