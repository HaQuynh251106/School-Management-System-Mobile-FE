import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;
  @override
  List<Object?> get props => [user.id];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthLoginFailure extends AuthState {
  const AuthLoginFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

final class AuthForgotPasswordSent extends AuthState {
  const AuthForgotPasswordSent({
    required this.emailDeliveryAvailable,
    this.devResetToken,
  });
  final bool emailDeliveryAvailable;
  final String? devResetToken;
  @override
  List<Object?> get props => [emailDeliveryAvailable, devResetToken];
}

final class AuthForgotPasswordFailed extends AuthState {
  const AuthForgotPasswordFailed(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
