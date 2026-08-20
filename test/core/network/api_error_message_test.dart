import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_error_message.dart';

void main() {
  DioException responseError(int statusCode, Map<String, dynamic> data) {
    final options = RequestOptions(path: '/grades/bulk');
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  test('grade conflict has a clear message and is marked for reload', () {
    final error = responseError(409, {
      'message': 'Điểm đã được người khác cập nhật',
    });

    expect(isApiConflict(error), isTrue);
    expect(gradeSaveErrorMessage(error), contains('đã được tải lại'));
    expect(gradeSaveErrorMessage(error), isNot(contains('DioException')));
  });

  test('technical expectedVersion response is not exposed to users', () {
    final error = responseError(400, {
      'message': 'Thiếu expectedVersion khi sửa điểm đã tồn tại',
    });

    final message = gradeSaveErrorMessage(error);
    expect(message, contains('chưa đồng bộ'));
    expect(message, isNot(contains('expectedVersion')));
    expect(message, isNot(contains('DioException')));
  });

  test('generic API errors use backend message without exception details', () {
    final error = responseError(400, {'message': 'Điểm phải từ 0 đến 10'});

    expect(
      apiErrorMessage(error, fallback: 'Không thể lưu'),
      'Điểm phải từ 0 đến 10',
    );
  });
}
