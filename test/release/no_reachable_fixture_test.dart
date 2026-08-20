import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production source does not contain known fixture or fake-success hooks',
    () {
      const forbidden = <String>[
        'sandboxCallback',
        'SKIP_INVALID',
        '_weekSlots',
        '_parentThreads',
        'Slide_HamSoBacHai.pdf',
        'BaiTap_Tuan',
        '5616000000',
        'Đang phát triển',
        'SSE mock API',
      ];

      final violations = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        for (final marker in forbidden) {
          if (source.contains(marker)) {
            violations.add('${entity.path}: $marker');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Không được phát hành UI có fixture/fake-success:\n'
            '${violations.join('\n')}',
      );
    },
  );

  test('repository does not ship a runnable mock API or fixture database', () {
    expect(File('mock-server/server.js').existsSync(), isFalse);
    expect(File('mock-server/db.json').existsSync(), isFalse);
  });
}
