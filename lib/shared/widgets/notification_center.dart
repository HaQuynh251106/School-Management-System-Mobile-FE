import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.read = false,
  });

  final String title;
  final String body;
  final String time;
  final String category;
  final bool read;
}

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({
    super.key,
    required this.accent,
    required this.items,
  });

  final Color accent;
  final List<NotificationItem> items;

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

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đánh dấu tất cả là đã đọc'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
        body: TabBarView(
          children: [
            _NotiList(items: items, accent: accent),
            _NotiList(items: unread, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _NotiList extends StatelessWidget {
  const _NotiList({required this.items, required this.accent});
  final List<NotificationItem> items;
  final Color accent;

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
          color: item.read ? null : color.withOpacity(0.04),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.12),
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
                        color: color.withOpacity(0.08),
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
            onTap: () {},
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
