import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  late Dio dio;
  late ApiService api;
  late List<RequestOptions> requests;

  setUp(() {
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: <String, dynamic>{'id': 'created-id'},
          ));
        },
      ),
    );
    api = ApiService(dio);
  });

  test('creates a user through the real backend contract', () async {
    await api.createUser({
      'username': 'hs.test',
      'password': 'Password123@',
      'fullName': 'Học sinh kiểm thử',
      'role': 'STUDENT',
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/users');
    expect((requests.single.data as Map)['role'], 'STUDENT');
  });

  test('creates and publishes an assignment with its class and subject',
      () async {
    await api.createAssignment({
      'classId': 'class-10a1',
      'subjectId': 'subject-math',
      'title': 'Bài tập chương 1',
      'publishNow': true,
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/assignments');
    expect((requests.single.data as Map)['classId'], 'class-10a1');
    expect((requests.single.data as Map)['publishNow'], isTrue);
  });
}
