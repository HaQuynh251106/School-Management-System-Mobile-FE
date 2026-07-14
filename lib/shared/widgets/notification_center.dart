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
    this.read = false,
  });

  /// Backend id (null cho mock data tĩnh).
  final String? id;
  final String title;
  final String body;
  final String time;
  final String category;
  final bool read;

  /// Map 1 notification từ REST backend sang model mà list row đang render.
  /// API: {id, type, title, body, read(bool), createdAt(ISO String)}
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      category: (json['type'] ?? '').toString(),
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
      case 'ATTENDANCE_ALERT':
        return (Icons.event_busy_rounded, AppColors.absentUnexcused);
      case 'GRADE_PUBLISHED':
        return (Icons.stars_rounded, AppColors.success);
      case 'ASSIGNMENT':
        return (Icons.assignment_outlined, AppColors.primary);
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
      case 'ATTENDANCE_ALERT':
        return 'Chuyên cần';
      case 'GRADE_PUBLISHED':
        return 'Điểm số';
      case 'ASSIGNMENT':
        return 'Bài tập';
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
        return Container(
          color: item.read ? null : color.withValues(alpha: 0.04),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
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
                    const SizedBox(width: 6),
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

// Mock data có thể dùng cho mọi role
const mockNotifications = <NotificationItem>[
  NotificationItem(
    title: 'Học sinh vắng mặt',
    body: 'Phạm Hoài An vắng tiết 1 ngày 22/05 — Tiếng Anh',
    time: '5 phút trước',
    category: 'ATTENDANCE_ALERT',
  ),
  NotificationItem(
    title: 'Điểm mới',
    body: 'Bạn vừa nhận điểm GK môn Toán: 8.8',
    time: '2 giờ trước',
    category: 'GRADE_PUBLISHED',
  ),
  NotificationItem(
    title: 'Bài tập mới',
    body: 'GV Trần Thị Hoa giao bài "Hàm số bậc hai" — hạn 28/05 23:59',
    time: '5 giờ trước',
    category: 'ASSIGNMENT',
  ),
  NotificationItem(
    title: 'Hóa đơn HK2 đã phát hành',
    body: 'HD-2025-HK2-0042 — Tổng 4.500.000 ₫ — Hạn 15/06',
    time: 'Hôm qua',
    category: 'INVOICE',
    read: true,
  ),
  NotificationItem(
    title: 'Thanh toán thành công',
    body: 'VNPAY: HD-2025-HK1-0042 — 4.500.000 ₫',
    time: '12/12/2025',
    category: 'PAYMENT',
    read: true,
  ),
  NotificationItem(
    title: 'Khóa ngoại khóa mở đăng ký',
    body: 'STEM — Lập trình Python — Còn 5/15 chỗ',
    time: '2 ngày trước',
    category: 'EXTRACURRICULAR',
    read: true,
  ),
  NotificationItem(
    title: 'Thông báo chung',
    body: 'Lịch thi GK đã được cập nhật — kiểm tra TKB mới',
    time: '3 ngày trước',
    category: 'ANNOUNCEMENT',
    read: true,
  ),
];
