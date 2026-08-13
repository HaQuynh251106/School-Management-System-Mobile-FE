import 'package:dio/dio.dart';
import '../config/env.dart';
import '../storage/token_storage.dart';

Dio createDioClient(TokenStorage storage) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(_AuthInterceptor(dio, storage));
  return dio;
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final status = err.response?.statusCode;
    final isAuthEndpoint = request.path.contains('/auth/');

    // Chỉ xử lý refresh cho 401 đến từ API thường.
    // Nếu chính endpoint /auth/* trả 401 (refresh/login hết hạn) thì KHÔNG
    // được gọi refresh lại — sẽ gây đệ quy + deadlock của QueuedInterceptor,
    // làm getMe() treo mãi và app kẹt ở splash.
    if (status != 401 ||
        isAuthEndpoint ||
        request.extra['retriedAfterRefresh'] == true) {
      if (status == 401 && isAuthEndpoint) {
        await _storage.clearAll();
      }
      return handler.next(err);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      await _storage.clearAll();
      return handler.next(err);
    }

    // Dùng Dio "trần" (không interceptor) cho cả refresh lẫn retry để KHÔNG
    // tái nhập onError của chính interceptor này.
    final bare = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    try {
      final resp = await bare.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newAccess = resp.data['accessToken'] as String;
      final newRefresh = (resp.data['refreshToken'] as String?) ?? refreshToken;
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      final retryOpts = err.requestOptions;
      retryOpts.extra['retriedAfterRefresh'] = true;
      retryOpts.headers['Authorization'] = 'Bearer $newAccess';
      final retryResp = await bare.fetch(retryOpts);
      return handler.resolve(retryResp);
    } catch (_) {
      // Refresh thất bại → xóa token cũ và để lỗi nổi lên (app về login).
      await _storage.clearAll();
      return handler.next(err);
    }
  }
}
