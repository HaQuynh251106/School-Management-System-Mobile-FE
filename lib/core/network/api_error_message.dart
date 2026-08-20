import 'package:dio/dio.dart';

String apiErrorMessage(Object? error, {required String fallback}) {
  if (error is DioException) {
    final message = _responseMessage(error.response?.data);
    if (message != null) return message;
  }
  return fallback;
}

bool isApiConflict(Object? error) =>
    error is DioException && error.response?.statusCode == 409;

String gradeSaveErrorMessage(Object? error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final message = _responseMessage(error.response?.data);
    if (statusCode == 409) {
      return 'Điểm đã được người khác cập nhật. Bảng điểm đã được tải lại; '
          'vui lòng kiểm tra và thử lại.';
    }
    if (statusCode == 400 &&
        message?.toLowerCase().contains('expectedversion') == true) {
      return 'Dữ liệu điểm chưa đồng bộ. Vui lòng tải lại bảng điểm và thử lại.';
    }
    if (message != null) return message;
  }
  return 'Không thể lưu điểm. Vui lòng thử lại.';
}

String? _responseMessage(Object? data) {
  if (data is! Map) return null;
  final value = data['message'] ?? data['error'];
  final message = value?.toString().trim();
  return message == null || message.isEmpty ? null : message;
}
