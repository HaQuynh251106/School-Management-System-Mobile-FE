import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';

class NotificationItem {
  const NotificationItem({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.priority = 'NORMAL',
    this.read = false,
  });

  /// Backend id (null cho mock data tĩnh).
  final String? id;
  final String title;
  final String body;
  final String time;
  final String category;
  final String priority;
  final bool read;

  /// Map 1 notification từ REST backend sang model mà list row đang render.
  /// API: {id, type, title, body, read(bool), createdAt(ISO String)}
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      category: (json['type'] ?? '').toString(),
      priority: (json['priority'] ?? 'NORMAL').toString(),
      time: _formatTime(json['createdAt']),
      read: json['read'] == true,
    );
  }

  static String _formatTime(Object? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    return DateFormat('dd/MM HH:mm').format(dt.toLocal());
  }
}

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({
    super.key,
    required this.accent,
  });

  final Color accent;

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();

  static (IconData, Color) _styleFor(String category) {
    switch (category) {
      case 'ATTENDANCE':
      case 'ATTENDANCE_ALERT':
        return (Icons.event_busy_rounded, AppColors.absentUnexcused);
      case 'GRADE':
      case 'GRADE_PUBLISHED':
        return (Icons.stars_rounded, AppColors.success);
      case 'HOLIDAY':
        return (Icons.beach_access_rounded, AppColors.teacherAccent);
      case 'EVENT':
        return (Icons.celebration_rounded, AppColors.adminAccent);
      case 'STUDENT_STATUS':
        return (Icons.school_rounded, AppColors.primary);
      case 'PARENT_MEETING':
        return (Icons.groups_rounded, AppColors.warning);
      case 'GENERAL':
        return (Icons.campaign_rounded, AppColors.adminAccent);
      case 'ASSIGNMENT':
        return (Icons.assignment_outlined, AppColors.primary);
      case 'FEE':
      case 'INVOICE':
        return (Icons.receipt_long_rounded, AppColors.warning);
      case 'PAYMENT':
        return (Icons.payment_rounded, AppColors.success);
      case 'ANNOUNCEMENT':
        return (Icons.campaign_rounded, AppColors.adminAccent);
      case 'EXTRACURRICULAR':
        return (Icons.sports_basketball_rounded, AppColors.teacherAccent);
      default:
        return (Icons.notifications_outlined, AppColors.textSecondary);
    }
  }

  static String _categoryLabel(String category) {
    switch (category) {
      case 'ATTENDANCE':
        return 'Điểm danh';
      case 'ATTENDANCE_ALERT':
        return 'Chuyên cần';
      case 'GRADE':
        return 'Điểm số';
      case 'GRADE_PUBLISHED':
        return 'Điểm số';
      case 'HOLIDAY':
        return 'Nghỉ lễ';
      case 'EVENT':
        return 'Sự kiện';
      case 'STUDENT_STATUS':
        return 'Tình hình học sinh';
      case 'PARENT_MEETING':
        return 'Họp phụ huynh';
      case 'GENERAL':
        return 'Thông báo chung';
      case 'ASSIGNMENT':
        return 'Bài tập';
      case 'FEE':
        return 'Khoản thu';
      case 'INVOICE':
        return 'Hóa đơn';
      case 'PAYMENT':
        return 'Thanh toán';
      case 'ANNOUNCEMENT':
        return 'Thông báo chung';
      case 'EXTRACURRICULAR':
        return 'Ngoại khóa';
      default:
        return category;
    }
  }
}

class LiveNotificationAction extends StatefulWidget {
  const LiveNotificationAction(
      {super.key, required this.accent, this.padding = 4});
  final Color accent;
  final double padding;

  @override
  State<LiveNotificationAction> createState() => _LiveNotificationActionState();
}

class _LiveNotificationActionState extends State<LiveNotificationAction> {
  late Future<int> _count = sl<ApiService>().notificationUnreadCount();

  Future<void> _open() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NotificationCenter(accent: widget.accent),
    ));
    if (mounted) {
      setState(() => _count = sl<ApiService>().notificationUnreadCount());
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(right: widget.padding),
        child: FutureBuilder<int>(
          future: _count,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return Stack(children: [
              IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: _open),
              if (count > 0)
                Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 14),
                      decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(count > 99 ? '99+' : '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    )),
            ]);
          },
        ),
      );
}

class _NotificationCenterState extends State<NotificationCenter> {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().notifications();

  void _refresh() {
    setState(() {
      _future = sl<ApiService>().notifications();
    });
  }

  Future<void> _markRead(NotificationItem item) async {
    final id = item.id;
    if (id == null || id.isEmpty || item.read) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<ApiService>().markNotiRead(id);
      if (!mounted) return;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _markAllRead(List<NotificationItem> items) async {
    final messenger = ScaffoldMessenger.of(context);
    final unreadIds = items
        .where((n) => !n.read && n.id != null && n.id!.isNotEmpty)
        .map((n) => n.id!)
        .toList();
    if (unreadIds.isEmpty) return;
    try {
      final api = sl<ApiService>();
      await Future.wait(unreadIds.map(api.markNotiRead));
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPreferences() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _NotificationPreferenceSheet(accent: widget.accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final items = (snap.data ?? []).map(NotificationItem.fromJson).toList();
        final unread = items.where((n) => !n.read).toList();
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Thông báo'),
              backgroundColor: accent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Kênh nhận thông báo',
                  onPressed: _openPreferences,
                ),
                IconButton(
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: 'Đánh dấu tất cả đã đọc',
                  onPressed: () => _markAllRead(items),
                ),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Tất cả (${items.length})'),
                  Tab(text: 'Chưa đọc (${unread.length})'),
                ],
              ),
            ),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                    ? Center(
                        child: Text('Lỗi: ${snap.error}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : TabBarView(
                        children: [
                          _NotiList(
                              items: items, accent: accent, onTap: _markRead),
                          _NotiList(
                              items: unread, accent: accent, onTap: _markRead),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _NotiList extends StatelessWidget {
  const _NotiList({
    required this.items,
    required this.accent,
    required this.onTap,
  });
  final List<NotificationItem> items;
  final Color accent;
  final void Function(NotificationItem) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child: Text('Không có thông báo',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (_, i) {
        final item = items[i];
        final (icon, color) = NotificationCenter._styleFor(item.category);
        final isUrgent = item.priority == 'URGENT';
        final isImportant = item.priority == 'IMPORTANT';
        final priorityColor = isUrgent ? AppColors.error : AppColors.warning;
        return Container(
          decoration: BoxDecoration(
            color: item.read
                ? null
                : (isUrgent ? AppColors.error : color).withValues(alpha: 0.04),
            border: isUrgent
                ? const Border(
                    left: BorderSide(color: AppColors.error, width: 3),
                  )
                : null,
          ),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (!item.read)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: item.read ? FontWeight.w500 : FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.body,
                    style: const TextStyle(fontSize: 12, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        NotificationCenter._categoryLabel(item.category),
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isUrgent || isImportant)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isUrgent ? 'Khẩn cấp' : 'Quan trọng',
                          style: TextStyle(
                            fontSize: 10,
                            color: priorityColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(item.time,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () => onTap(item),
          ),
        );
      },
    );
  }
}

class _NotificationPreferenceSheet extends StatefulWidget {
  const _NotificationPreferenceSheet({required this.accent});
  final Color accent;

  @override
  State<_NotificationPreferenceSheet> createState() =>
      _NotificationPreferenceSheetState();
}

class _NotificationPreferenceSheetState
    extends State<_NotificationPreferenceSheet> {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().notificationPreferences();

  String _label(String channel) => switch (channel) {
        'IN_APP' => 'Trong ứng dụng',
        'PUSH' => 'Thông báo đẩy',
        'EMAIL' => 'Email',
        _ => channel,
      };

  IconData _icon(String channel) => switch (channel) {
        'PUSH' => Icons.phone_android_rounded,
        'EMAIL' => Icons.email_outlined,
        _ => Icons.notifications_outlined,
      };

  Future<void> _toggle(String channel, bool enabled) async {
    await sl<ApiService>().updateNotificationPreference(channel, enabled);
    if (mounted) {
      setState(() => _future = sl<ApiService>().notificationPreferences());
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kênh nhận thông báo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Chọn cách nhà trường có thể gửi thông tin tới bạn.',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: (snap.data ?? const [])
                        .map((preference) => SwitchListTile(
                              secondary: Icon(
                                  _icon(preference['channel'].toString()),
                                  color: widget.accent),
                              title: Text(
                                  _label(preference['channel'].toString())),
                              value: preference['enabled'] == true,
                              activeThumbColor: widget.accent,
                              onChanged: (enabled) => _toggle(
                                  preference['channel'].toString(), enabled),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );
}
