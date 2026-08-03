import 'package:flutter/material.dart';

/// Lớp nền phẳng dùng chung cho ứng dụng.
class AppAuroraBackground extends StatelessWidget {
  const AppAuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF101722)
        : const Color(0xFFF5F7FA),
    child: child,
  );
}

/// Bề mặt Material tiêu chuẩn. Tên lớp được giữ để không làm thay đổi API của
/// các màn hình đang sử dụng thành phần này.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.blur = 0,
    this.opacity,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double? opacity;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (dark ? const Color(0xFF182230) : Colors.white)
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (dark ? const Color(0xFF2A3747) : const Color(0xFFE0E5EC)),
        ),
      ),
      child: child,
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}

/// Thành phần tương tác tiêu chuẩn, chỉ sử dụng ripple của Material.
class PressableScale extends StatelessWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: borderRadius,
    child: InkWell(borderRadius: borderRadius, onTap: onTap, child: child),
  );
}

/// Không áp dụng hiệu ứng xuất hiện; giữ wrapper để tương thích mã hiện có.
class EntranceMotion extends StatelessWidget {
  const EntranceMotion({
    super.key,
    required this.child,
    this.index = 0,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final int index;
  final Axis axis;

  @override
  Widget build(BuildContext context) => child;
}
