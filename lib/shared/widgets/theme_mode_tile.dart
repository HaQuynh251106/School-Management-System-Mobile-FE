import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/theme_controller.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final controller = sl<ThemeController>();
    final effectiveAccent = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.primary
        : accent;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => ListTile(
        leading: Icon(
          controller.mode == ThemeMode.dark
              ? Icons.dark_mode_rounded
              : controller.mode == ThemeMode.light
              ? Icons.light_mode_rounded
              : Icons.brightness_auto_rounded,
          color: effectiveAccent,
        ),
        title: const Text('Giao diện'),
        subtitle: Text(switch (controller.mode) {
          ThemeMode.light => 'Sáng',
          ThemeMode.dark => 'Tối',
          ThemeMode.system => 'Theo thiết bị',
        }),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn giao diện',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final mode in ThemeMode.values)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selected: controller.mode == mode,
                    selectedColor: effectiveAccent,
                    leading: Icon(switch (mode) {
                      ThemeMode.system => Icons.brightness_auto_rounded,
                      ThemeMode.light => Icons.light_mode_rounded,
                      ThemeMode.dark => Icons.dark_mode_rounded,
                    }),
                    title: Text(switch (mode) {
                      ThemeMode.system => 'Theo cài đặt thiết bị',
                      ThemeMode.light => 'Giao diện sáng',
                      ThemeMode.dark => 'Giao diện tối',
                    }),
                    trailing: controller.mode == mode
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: effectiveAccent,
                          )
                        : null,
                    onTap: () async {
                      await controller.setMode(mode);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
