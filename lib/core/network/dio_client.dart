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
    if (err.response?.statusCode != 401 ||
        request.path == '/auth/refresh' ||
        request.extra['retriedAfterRefresh'] == true) {
      return handler.next(err);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      await _storage.clearAll();
      return handler.next(err);
    }

    try {
      final resp = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final newAccess = resp.data['accessToken'] as String;
      final newRefresh = resp.data['refreshToken'] as String;
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      final retryOpts = err.requestOptions;
      retryOpts.extra['retriedAfterRefresh'] = true;
      retryOpts.headers['Authorization'] = 'Bearer $newAccess';
      final retryResp = await _dio.fetch(retryOpts);
      return handler.resolve(retryResp);
    } catch (_) {
      await _storage.clearAll();
      handler.next(err);
    }
  }
}
