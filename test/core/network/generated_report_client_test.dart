import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  test(
    'ApiService reads dashboard and reports through generated client',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.httpClientAdapter = _ReportAdapter(requests);
      final api = ApiService(dio);

      final dashboard = await api.dashboard(childId: 'u-student-1');
      final personal = await api.personalReport(childId: 'u-student-1');
      final overview = await api.reportOverview();
      final grades = await api.reportGradeDistribution(
        semesterId: 'sm-1',
        classId: 'c-10a1',
        subjectId: 'sj-math',
      );
      final attendance = await api.reportAttendance(
        classId: 'c-10a1',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
      );
      final revenue = await api.reportRevenue(
        periodId: 'fp-hk1',
        classId: 'c-10a1',
      );

      expect(dashboard['scope']['role'], 'PARENT');
      expect(personal['averageScore'], 8.2);
      expect(overview['students'], 2);
      expect(grades.single['band'], '8-10');
      expect(attendance['attendanceRate'], 90.0);
      expect(revenue['outstanding'], 200000);
      expect(requests.map((request) => request.path), [
        '/dashboard',
        '/me/reports',
        '/reports/overview',
        '/reports/grade-distribution',
        '/reports/attendance-summary',
        '/reports/revenue',
      ]);
      expect(requests[0].queryParameters['childId'], 'u-student-1');
      expect(requests[3].queryParameters, {
        'semesterId': 'sm-1',
        'classId': 'c-10a1',
        'subjectId': 'sj-math',
      });
      expect(requests[4].queryParameters['startDate'], DateTime(2026, 8, 1));
      expect(requests[4].queryParameters['endDate'], DateTime(2026, 8, 31));
    },
  );

  test('ApiService downloads typed report bytes with filters', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _ReportAdapter(requests);
    final api = ApiService(dio);

    final adminBytes = await api.exportReport(
      type: 'attendance',
      format: 'pdf',
      classId: 'c-10a1',
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
    );
    final personalBytes = await api.exportPersonalReport(
      childId: 'u-student-1',
    );

    expect(adminBytes, [37, 80, 68, 70]);
    expect(personalBytes, utf8.encode('personal,csv'));
    expect(requests[0].responseType, ResponseType.bytes);
    expect(requests[0].queryParameters['type'], 'attendance');
    expect(requests[0].queryParameters['format'], 'pdf');
    expect(requests[1].queryParameters['childId'], 'u-student-1');
  });
}

class _ReportAdapter implements HttpClientAdapter {
  _ReportAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/reports/export') {
      return ResponseBody.fromBytes([37, 80, 68, 70], 200);
    }
    if (options.path == '/me/reports/export') {
      return ResponseBody.fromBytes(utf8.encode('personal,csv'), 200);
    }
    final body = switch (options.path) {
      '/dashboard' => _dashboard,
      '/me/reports' => _personal,
      '/reports/overview' => _overview,
      '/reports/grade-distribution' => [_gradeBand],
      '/reports/attendance-summary' => _attendance,
      '/reports/revenue' => _revenue,
      _ => throw StateError('Unexpected request ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _dashboard = {
  'asOf': '2026-08-12T12:00:00Z',
  'scope': {
    'role': 'PARENT',
    'objectType': 'STUDENT',
    'objectIds': ['u-student-1'],
  },
  'metrics': [
    {
      'key': 'grades',
      'label': 'Diem trung binh',
      'value': 8.2,
      'format': 'DECIMAL_1',
      'hint': 'Du lieu that',
      'tone': 'violet',
      'trend': {'direction': 'NONE', 'label': 'Chua du du lieu'},
    },
  ],
  'charts': [
    {
      'title': 'Ket qua',
      'subtitle': 'Theo mon',
      'type': 'COLUMN',
      'suffix': ' diem',
      'max': 10.0,
      'data': [
        {'label': 'Toan', 'value': 8.2},
      ],
    },
  ],
  'shortcuts': [
    {
      'key': 'grades',
      'label': 'Xem diem',
      'target': 'grades',
      'filters': {'childId': 'u-student-1'},
    },
  ],
  'errors': [],
};
const _personal = {
  'role': 'PARENT',
  'studentCount': 1,
  'classCount': 1,
  'gradeCount': 3,
  'averageScore': 8.2,
  'subjectAverages': {'Toan': 8.2},
  'attendanceTotal': 10,
  'present': 9,
  'late': 0,
  'absentExcused': 1,
  'absentUnexcused': 0,
  'attendanceRate': 90.0,
  'submissionCount': 2,
  'gradedSubmissionCount': 1,
  'finance': {
    'invoiceCount': 1,
    'paidInvoiceCount': 0,
    'totalAmount': 500000,
    'paidAmount': 300000,
    'outstanding': 200000,
  },
};
const _overview = {
  'students': 2,
  'teachers': 2,
  'parents': 1,
  'admins': 1,
  'classes': 3,
  'subjects': 5,
};
const _gradeBand = {'band': '8-10', 'count': 3};
const _attendance = {
  'present': 9,
  'late': 0,
  'absentExcused': 1,
  'absentUnexcused': 0,
  'total': 10,
  'attendanceRate': 90.0,
};
const _revenue = {
  'invoiceCount': 1,
  'paidCount': 0,
  'totalAmount': 500000,
  'paidAmount': 300000,
  'outstanding': 200000,
};
