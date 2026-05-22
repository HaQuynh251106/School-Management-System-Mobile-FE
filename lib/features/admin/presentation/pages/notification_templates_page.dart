import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class _Template {
  const _Template({
    required this.code,
    required this.name,
    required this.category,
    required this.channel,
    required this.subject,
    required this.body,
    this.active = true,
  });
  final String code;
  final String name;
  final String category;
  final String channel;
  final String subject;
  final String body;
  final bool active;
}

class NotificationTemplatesPage extends StatelessWidget {
  const NotificationTemplatesPage({super.key});

  static const _templates = [
    _Template(
      code: 'ATTENDANCE_ABSENT_PUSH',
      name: 'Cảnh báo vắng - Push',
      category: 'ATTENDANCE_ALERT',
      channel: 'PUSH',
      subject: 'Học sinh vắng mặt',
      body:
          'Học sinh {{studentName}} vắng tiết {{period}} ngày {{date}}.',
    ),
    _Template(
      code: 'ATTENDANCE_ABSENT_EMAIL',
      name: 'Cảnh báo vắng - Email',
      category: 'ATTENDANCE_ALERT',
      channel: 'EMAIL',
      subject: '[Smart School] Thông báo vắng mặt',
      body:
          'Kính gửi PH {{parentName}}, học sinh {{studentName}} đã vắng '
          'tiết {{period}} ngày {{date}}. Lý do: {{reason}}.',
    ),
    _Template(
      code: 'INVOICE_ISSUED_EMAIL',
      name: 'Hóa đơn mới - Email',
      category: 'INVOICE',
      channel: 'EMAIL',
      subject: '[Smart School] Hóa đơn học phí {{invoiceCode}}',
      body:
          'Hóa đơn {{invoiceCode}} trị giá {{totalAmount}} VNĐ, hạn {{dueDate}}.',
    ),
    _Template(
      code: 'GRADE_PUBLISHED_PUSH',
      name: 'Có điểm mới',
      category: 'GRADE_PUBLISHED',
      channel: 'PUSH',
      subject: 'Điểm mới',
      body: 'Bạn vừa nhận điểm môn {{subject}}: {{score}}.',
    ),
    _Template(
      code: 'ASSIGNMENT_PUBLISHED_PUSH',
      name: 'Bài tập mới',
      category: 'ASSIGNMENT',
      channel: 'PUSH',
      subject: 'Bài tập mới',
      body:
          'GV {{teacherName}} giao bài "{{title}}" — hạn {{deadline}}.',
    ),
    _Template(
      code: 'PAYMENT_SUCCESS_EMAIL',
      name: 'Thanh toán thành công',
      category: 'PAYMENT',
      channel: 'EMAIL',
      subject: '[Smart School] Biên nhận thanh toán {{invoiceCode}}',
      body:
          'Cảm ơn anh chị đã thanh toán hóa đơn {{invoiceCode}}. '
          'Số tiền: {{amount}} VNĐ qua {{method}}.',
    ),
  ];

  static (Color, IconData) _channelStyle(String channel) {
    switch (channel) {
      case 'PUSH':
        return (AppColors.studentAccent, Icons.notifications_active_rounded);
      case 'EMAIL':
        return (AppColors.parentAccent, Icons.email_outlined);
      case 'IN_APP':
        return (AppColors.teacherAccent, Icons.app_settings_alt_outlined);
      default:
        return (AppColors.textSecondary, Icons.message_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template thông báo'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Tạo template',
              onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _templates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final t = _templates[i];
          final (color, icon) = _channelStyle(t.channel);
          return Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showEdit(context, t),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text(t.code,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Switch(
                          value: t.active,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.channel == 'EMAIL') ...[
                            Text(t.subject,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                          ],
                          Text(t.body,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _Chip(label: t.category, color: AppColors.adminAccent),
                        _Chip(label: t.channel, color: color),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEdit(BuildContext context, _Template t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(t.code,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              if (t.channel == 'EMAIL')
                TextField(
                  controller: TextEditingController(text: t.subject),
                  decoration: const InputDecoration(
                      labelText: 'Subject (tiêu đề)', isDense: true),
                ),
              if (t.channel == 'EMAIL') const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: t.body),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Body (Handlebars syntax)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Biến hỗ trợ: {{studentName}} {{parentName}} {{teacherName}} '
                '{{period}} {{date}} {{score}} {{subject}} {{invoiceCode}} '
                '{{totalAmount}} {{dueDate}}',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Test gửi'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu template'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.adminAccent),
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
