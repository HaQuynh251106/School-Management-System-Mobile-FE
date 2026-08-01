import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
  }

  final AuthRepository _repository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final user = await _repository.tryRestoreSession();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(
        username: event.username,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map<String, dynamic>
          ? (responseData['error'] ?? responseData['message'])?.toString() ??
              'Đăng nhập thất bại, vui lòng thử lại.'
          : 'Đăng nhập thất bại, vui lòng thử lại.';
      emit(AuthLoginFailure(msg));
    } catch (_) {
      emit(const AuthLoginFailure('Có lỗi xảy ra, vui lòng thử lại.'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.forgotPassword(event.email);
      emit(const AuthForgotPasswordSent());
    } catch (_) {
      emit(const AuthForgotPasswordSent());
    }
  }
}
