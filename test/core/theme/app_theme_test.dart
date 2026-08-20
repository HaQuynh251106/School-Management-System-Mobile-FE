import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/theme/app_theme.dart';

void main() {
  test('màu hành động chính đủ tương phản ở cả hai giao diện', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final colors = theme.colorScheme;
      expect(
        _contrast(colors.primary, colors.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('các điều khiển chính có vùng chạm tối thiểu 48 px', () {
    final theme = AppTheme.light;
    expect(theme.listTileTheme.minTileHeight, greaterThanOrEqualTo(48));
    expect(
      theme.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(48),
    );
    expect(
      theme.elevatedButtonTheme.style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(48),
    );
  });

  test('AppBar và nội dung luôn đủ tương phản ở cả hai giao diện', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final appBar = theme.appBarTheme;
      expect(
        _contrast(appBar.backgroundColor!, appBar.foregroundColor!),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(theme.colorScheme.surface, theme.colorScheme.onSurface),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

double _contrast(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final darker = first.computeLuminance() > second.computeLuminance()
      ? second.computeLuminance()
      : first.computeLuminance();
  return (lighter + .05) / (darker + .05);
}
