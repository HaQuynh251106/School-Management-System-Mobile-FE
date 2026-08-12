import 'package:sse_identity_api/src/model/admin_reset_password_request.dart';
import 'package:sse_identity_api/src/model/admin_reset_password_response.dart';
import 'package:sse_identity_api/src/model/api_error.dart';
import 'package:sse_identity_api/src/model/change_password_request.dart';
import 'package:sse_identity_api/src/model/change_password_response.dart';
import 'package:sse_identity_api/src/model/create_user_request.dart';
import 'package:sse_identity_api/src/model/forgot_password_request.dart';
import 'package:sse_identity_api/src/model/forgot_password_response.dart';
import 'package:sse_identity_api/src/model/login_request.dart';
import 'package:sse_identity_api/src/model/login_response.dart';
import 'package:sse_identity_api/src/model/logout_request.dart';
import 'package:sse_identity_api/src/model/ok_response.dart';
import 'package:sse_identity_api/src/model/refresh_request.dart';
import 'package:sse_identity_api/src/model/reset_password_request.dart';
import 'package:sse_identity_api/src/model/token_response.dart';
import 'package:sse_identity_api/src/model/update_my_profile_request.dart';
import 'package:sse_identity_api/src/model/user.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AdminResetPasswordRequest':
      return AdminResetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminResetPasswordResponse':
      return AdminResetPasswordResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiError':
      return ApiError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ChangePasswordRequest':
      return ChangePasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordResponse':
      return ChangePasswordResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateUserRequest':
      return CreateUserRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordRequest':
      return ForgotPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordResponse':
      return ForgotPasswordResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginRequest':
      return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginResponse':
      return LoginResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LogoutRequest':
      return LogoutRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OkResponse':
      return OkResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RefreshRequest':
      return RefreshRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResetPasswordRequest':
      return ResetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokenResponse':
      return TokenResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateMyProfileRequest':
      return UpdateMyProfileRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'User':
      return User.fromJson(value as Map<String, dynamic>) as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
