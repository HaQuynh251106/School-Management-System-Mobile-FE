import 'package:test/test.dart';
import 'package:sse_identity_api/sse_identity_api.dart';


/// tests for IdentityApi
void main() {
  final instance = SseIdentityApi().getIdentityApi();

  group(IdentityApi, () {
    //Future<AdminResetPasswordResponse> adminResetUserPassword(String id, { AdminResetPasswordRequest adminResetPasswordRequest }) async
    test('test adminResetUserPassword', () async {
      // TODO
    });

    //Future<ChangePasswordResponse> changeMyPassword(ChangePasswordRequest changePasswordRequest) async
    test('test changeMyPassword', () async {
      // TODO
    });

    //Future<User> createUser(CreateUserRequest createUserRequest) async
    test('test createUser', () async {
      // TODO
    });

    //Future<ForgotPasswordResponse> forgotPassword(ForgotPasswordRequest forgotPasswordRequest) async
    test('test forgotPassword', () async {
      // TODO
    });

    //Future<User> getCurrentUser() async
    test('test getCurrentUser', () async {
      // TODO
    });

    //Future<User> getUser(String id) async
    test('test getUser', () async {
      // TODO
    });

    //Future<List<User>> listUsers({ String role, String q, String classId }) async
    test('test listUsers', () async {
      // TODO
    });

    //Future<User> lockUser(String id) async
    test('test lockUser', () async {
      // TODO
    });

    //Future<LoginResponse> login(LoginRequest loginRequest) async
    test('test login', () async {
      // TODO
    });

    //Future<OkResponse> logout({ LogoutRequest logoutRequest }) async
    test('test logout', () async {
      // TODO
    });

    //Future<TokenResponse> refreshSession({ RefreshRequest refreshRequest }) async
    test('test refreshSession', () async {
      // TODO
    });

    //Future<OkResponse> resetPassword(ResetPasswordRequest resetPasswordRequest) async
    test('test resetPassword', () async {
      // TODO
    });

    //Future<User> unlockUser(String id) async
    test('test unlockUser', () async {
      // TODO
    });

    //Future<User> updateMyProfile(UpdateMyProfileRequest updateMyProfileRequest) async
    test('test updateMyProfile', () async {
      // TODO
    });

  });
}
