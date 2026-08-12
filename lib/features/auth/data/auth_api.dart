import 'package:dio/dio.dart';
import 'package:sse_identity_api/sse_identity_api.dart' as identity;

import 'models/user_model.dart';

class AuthApi {
  AuthApi(Dio dio) : _api = identity.IdentityApi(dio);

  final identity.IdentityApi _api;

  Future<identity.LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _api.login(
      loginRequest: identity.LoginRequest(
        username: username,
        password: password,
      ),
    );
    return response.data!;
  }

  Future<identity.TokenResponse> refresh(String refreshToken) async {
    final response = await _api.refreshSession(
      refreshRequest: identity.RefreshRequest(refreshToken: refreshToken),
    );
    return response.data!;
  }

  Future<void> forgotPassword(String email) async {
    await _api.forgotPassword(
      forgotPasswordRequest: identity.ForgotPasswordRequest(email: email),
    );
  }

  Future<UserModel> getMe() async {
    final response = await _api.getCurrentUser();
    return UserModel.fromJson(response.data!.toJson());
  }

  Future<void> logout(String? refreshToken) async {
    await _api.logout(
      logoutRequest: identity.LogoutRequest(refreshToken: refreshToken),
    );
  }
}
