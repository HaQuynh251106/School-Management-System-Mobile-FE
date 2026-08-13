import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../data/auth_repository.dart';
import '../../../../core/network/realtime_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    RealtimeService? realtime,
  })  : _repository = repository,
        _realtime = realtime,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
  }

  final AuthRepository _repository;
  final RealtimeService? _realtime;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final user = await _repository.tryRestoreSession();
    if (user != null) {
      await _realtime?.restartForAuthenticatedSession();
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
      await _realtime?.restartForAuthenticatedSession();
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
    _realtime?.disconnect();
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _repository.forgotPassword(event.email);
      emit(AuthForgotPasswordSent(
        emailDeliveryAvailable: result['deliveryChannel'] == 'EMAIL',
        devResetToken: result['devResetToken']?.toString(),
      ));
    } catch (_) {
      emit(const AuthForgotPasswordFailed(
          'Không thể kết nối máy chủ. Vui lòng thử lại.'));
    }
  }
}
