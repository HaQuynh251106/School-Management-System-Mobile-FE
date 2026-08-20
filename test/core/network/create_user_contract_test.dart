import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  late ApiService api;
  late List<RequestOptions> requests;

  setUp(() {
    requests = [];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'teacher-1',
                'username': 'gv.test',
                'fullName': 'Giáo viên kiểm thử',
                'role': 'TEACHER',
                'status': 'ACTIVE',
                'passwordChangeRequired': true,
              },
            ),
          );
        },
      ),
    );
    api = ApiService(dio);
  });

  test(
    'create teacher sends required contacts and catalog subject id',
    () async {
      await api.createUser({
        'username': 'gv.test',
        'password': 'Password123@',
        'fullName': 'Giáo viên kiểm thử',
        'role': 'TEACHER',
        'email': 'teacher.test@example.edu.vn',
        'phone': '0912345678',
        'mainSubjectId': 'subject-math',
      });

      expect(requests.single.method, 'POST');
      expect(requests.single.path, '/users');
      final body = _requestData(requests.single);
      expect(body['email'], 'teacher.test@example.edu.vn');
      expect(body['phone'], '0912345678');
      expect(body['mainSubjectId'], 'subject-math');
      expect(body, isNot(contains('teacherCode')));
      expect(body, isNot(contains('studentCode')));
      expect(body, isNot(contains('mainSubject')));
    },
  );
}

Map<String, dynamic> _requestData(RequestOptions request) {
  final data = request.data;
  if (data is String) return (jsonDecode(data) as Map).cast<String, dynamic>();
  return (data as Map).cast<String, dynamic>();
}
