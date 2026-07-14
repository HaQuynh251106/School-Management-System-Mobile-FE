import 'package:dio/dio.dart';
import 'models/user_model.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final resp = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final resp = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<UserModel> getMe() async {
    final resp = await _dio.get('/me');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> logout(String? refreshToken) async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
