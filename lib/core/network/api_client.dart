import 'package:dio/dio.dart';

import '../../app/environment.dart';
import '../storage/token_vault.dart';

class ApiClient {
  ApiClient(this.vault, {void Function()? onUnauthorized}) {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio, vault, onUnauthorized));
  }

  final TokenVault vault;
  late final Dio dio;

  Future<Map<String, dynamic>> map(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.request(
      path,
      data: data,
      queryParameters: query,
      options: Options(method: method),
    );
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get(path, queryParameters: query);
    final raw = response.data;
    if (raw is List) {
      return raw.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    if (raw is Map && raw['items'] is List) {
      return (raw['items'] as List)
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (raw is Map && raw['content'] is List) {
      return (raw['content'] as List)
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> page(
    String path, {
    int page = 0,
    int size = 20,
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get(
      path,
      queryParameters: {...?query, 'page': page, 'size': size},
    );
    final raw = response.data;
    if (raw is Map) return raw.cast<String, dynamic>();
    if (raw is List) {
      return {
        'items': raw,
        'page': 0,
        'totalPages': 1,
        'totalElements': raw.length,
      };
    }
    return const {'items': []};
  }

  Future<Map<String, dynamic>> upload(
    String path,
    List<int> bytes,
    String fileName,
  ) async {
    final response = await dio.post(
      path,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      }),
    );
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> post(String path, Object? data) =>
      map(path, method: 'POST', data: data);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => map(path, query: query);

  Future<Map<String, dynamic>> put(String path, Object? data) =>
      map(path, method: 'PUT', data: data);

  Future<void> delete(String path) async => dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this.dio, this.vault, this.onUnauthorized);
  final Dio dio;
  final TokenVault vault;
  final void Function()? onUnauthorized;
  bool _refreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await vault.accessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        request.extra['retried'] == true ||
        request.path.startsWith('/auth/')) {
      handler.next(error);
      return;
    }
    if (_refreshing) {
      handler.next(error);
      return;
    }
    _refreshing = true;
    try {
      final refresh = await vault.refreshToken();
      if (refresh == null) throw StateError('Không có refresh token');
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(extra: {'retried': true}),
      );
      final data = (response.data as Map).cast<String, dynamic>();
      await vault.save(
        '${data['accessToken']}',
        '${data['refreshToken'] ?? refresh}',
      );
      request.headers['Authorization'] = 'Bearer ${data['accessToken']}';
      request.extra['retried'] = true;
      handler.resolve(await dio.fetch(request));
    } catch (_) {
      await vault.clear();
      onUnauthorized?.call();
      handler.next(error);
    } finally {
      _refreshing = false;
    }
  }
}
