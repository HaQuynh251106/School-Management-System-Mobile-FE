import 'package:flutter/material.dart';
import 'module_router.dart';

enum ModuleGroup {
  adminPeople,
  adminOperations,
  teacherTeaching,
  teacherWork,
  studentLearning,
  studentTasks,
  parentLearning,
  parentFinance,
}

class AppModule {
  const AppModule(
    this.title,
    this.subtitle,
    this.icon,
    this.endpoint, {
    this.createKind,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String endpoint;
  final String? createKind;
}

class ModuleHubScreen extends StatelessWidget {
  const ModuleHubScreen({super.key, required this.group, required this.accent});
  final ModuleGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final spec = _GroupSpec.of(group);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: .95),
            toolbarHeight: 86,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spec.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  spec.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
            sliver: SliverGrid.builder(
              itemCount: spec.modules.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 150,
                mainAxisSpacing: 13,
                crossAxisSpacing: 13,
              ),
              itemBuilder: (context, index) {
                final module = spec.modules[index];
                return _ModuleCard(
                  module: module,
                  accent: accent,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          buildModuleScreen(module: module, accent: accent),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.accent,
    required this.onTap,
  });
  final AppModule module;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(module.icon, color: accent, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    module.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    ),
  );
}

class _GroupSpec {
  const _GroupSpec(this.title, this.subtitle, this.modules);
  final String title;
  final String subtitle;
  final List<AppModule> modules;

  static _GroupSpec of(ModuleGroup group) => switch (group) {
    ModuleGroup.adminPeople =>
      const _GroupSpec('Con người', 'Quản lý hồ sơ và tổ chức nhà trường', [
        AppModule(
          'Người dùng',
          'Học sinh, giáo viên và phụ huynh',
          Icons.manage_accounts_outlined,
          '/users',
          createKind: 'user',
        ),
        AppModule(
          'Lớp học',
          'Khối, lớp và giáo viên chủ nhiệm',
          Icons.groups_2_outlined,
          '/classes',
          createKind: 'class',
        ),
        AppModule(
          'Môn học',
          'Danh mục môn và hệ số',
          Icons.menu_book_outlined,
          '/subjects',
          createKind: 'subject',
        ),
        AppModule(
          'Phòng học',
          'Phòng và ca sử dụng',
          Icons.meeting_room_outlined,
          '/rooms',
          createKind: 'room',
        ),
        AppModule(
          'Phân công bộ môn',
          'Lớp dạy và tải tuần của giáo viên',
          Icons.assignment_ind_outlined,
          '/teaching-assignments',
        ),
      ]),
    ModuleGroup.adminOperations =>
      const _GroupSpec('Vận hành', 'Điều phối các hoạt động toàn trường', [
        AppModule(
          'Năm học',
          'Năm học, học kỳ và tổng kết',
          Icons.calendar_month_outlined,
          '/academicYears',
          createKind: 'academicYear',
        ),
        AppModule(
          'Thời khóa biểu',
          'Lịch học theo lớp, ca và phòng',
          Icons.view_week_outlined,
          '/timetableSlots',
        ),
        AppModule(
          'Khảo thí',
          'Kỳ thi, lịch thi và phân công',
          Icons.fact_check_outlined,
          '/exam-periods',
          createKind: 'examPeriod',
        ),
        AppModule(
          'Khoản thu',
          'Đợt thu và trạng thái phát hành',
          Icons.payments_outlined,
          '/fee-periods',
          createKind: 'fee',
        ),
        AppModule(
          'Công nợ',
          'Theo dõi tiến độ tài chính theo khối và lớp',
          Icons.account_balance_wallet_outlined,
          '/finance/classes',
        ),
        AppModule(
          'Thông báo',
          'Truyền thông toàn trường',
          Icons.campaign_outlined,
          '/announcements',
          createKind: 'announcement',
        ),
      ]),
    ModuleGroup.teacherTeaching =>
      const _GroupSpec('Giảng dạy', 'Mọi công cụ cần cho một tiết học', [
        AppModule(
          'Lịch dạy',
          'Lịch hôm nay và cả tuần',
          Icons.calendar_view_week_outlined,
          '/me/timetable',
        ),
        AppModule(
          'Điểm danh',
          'Ghi nhận chuyên cần theo tiết',
          Icons.how_to_reg_outlined,
          '/attendance',
        ),
        AppModule(
          'Bảng điểm',
          'Điểm thành phần và tổng kết',
          Icons.table_chart_outlined,
          '/grades',
        ),
        AppModule(
          'Bài tập',
          'Giao, sửa, gia hạn và chấm bài',
          Icons.assignment_outlined,
          '/assignments',
          createKind: 'assignment',
        ),
        AppModule(
          'Lớp đang dạy',
          'Học sinh và thông tin lớp',
          Icons.co_present_outlined,
          '/me/teaching-classes',
        ),
      ]),
    ModuleGroup.teacherWork => const _GroupSpec(
      'Công việc',
      'Nhiệm vụ ngoài tiết dạy được ưu tiên rõ ràng',
      [
        AppModule(
          'Chấm thi',
          'Danh sách môn thi được phân công',
          Icons.edit_note_outlined,
          '/me/exam-grading',
        ),
        AppModule(
          'Đơn nghỉ học',
          'Duyệt đơn của lớp chủ nhiệm',
          Icons.event_busy_outlined,
          '/leave-requests',
        ),
        AppModule(
          'Công nợ lớp',
          'Theo dõi và nhắc hạn phụ huynh',
          Icons.account_balance_wallet_outlined,
          '/finance/classes',
        ),
        AppModule(
          'Thông báo lớp',
          'Gửi nội dung đến học sinh, phụ huynh',
          Icons.notifications_active_outlined,
          '/teacher/announcements',
          createKind: 'announcement',
        ),
      ],
    ),
    ModuleGroup.studentLearning =>
      const _GroupSpec('Học tập', 'Theo dõi tiến độ học tập của bạn', [
        AppModule(
          'Thời khóa biểu',
          'Lịch học theo ngày và tuần',
          Icons.calendar_view_week_outlined,
          '/me/timetable',
        ),
        AppModule(
          'Bảng điểm',
          'Điểm thành phần và trung bình',
          Icons.insights_outlined,
          '/grades',
        ),
        AppModule(
          'Chuyên cần',
          'Các buổi có mặt, vắng và đi muộn',
          Icons.how_to_reg_outlined,
          '/attendance',
        ),
        AppModule(
          'Lịch thi',
          'Lịch kiểm tra đã được công bố',
          Icons.event_note_outlined,
          '/me/exam-agenda',
        ),
      ]),
    ModuleGroup.studentTasks =>
      const _GroupSpec('Nhiệm vụ', 'Việc cần hoàn thành được sắp theo hạn', [
        AppModule(
          'Bài tập',
          'Bài đang làm, sắp đến hạn và đã nộp',
          Icons.assignment_outlined,
          '/me/assignments',
        ),
        AppModule(
          'Bài đã nộp',
          'Kết quả chấm và phản hồi giáo viên',
          Icons.cloud_done_outlined,
          '/me/submissions',
        ),
        AppModule(
          'Xin nghỉ học',
          'Tạo và theo dõi đơn xin nghỉ',
          Icons.event_busy_outlined,
          '/leave-requests',
          createKind: 'leave',
        ),
        AppModule(
          'Kết quả thi',
          'Điểm thi và yêu cầu phúc khảo',
          Icons.workspace_premium_outlined,
          '/me/exam-results',
        ),
      ]),
    ModuleGroup.parentLearning => const _GroupSpec(
      'Học tập của con',
      'Một nơi theo dõi đầy đủ và dễ hiểu',
      [
        AppModule(
          'Các con',
          'Chọn học sinh cần theo dõi',
          Icons.family_restroom_outlined,
          '/me/children',
        ),
        AppModule(
          'Thời khóa biểu',
          'Lịch học theo ngày và tuần',
          Icons.calendar_view_week_outlined,
          '/me/timetable',
        ),
        AppModule(
          'Bảng điểm',
          'Điểm thành phần và tổng kết',
          Icons.insights_outlined,
          '/grades',
        ),
        AppModule(
          'Bài tập',
          'Hạn nộp và tình trạng hoàn thành',
          Icons.assignment_outlined,
          '/me/assignments',
        ),
        AppModule(
          'Chuyên cần',
          'Theo dõi đi học và nghỉ học',
          Icons.how_to_reg_outlined,
          '/attendance',
        ),
      ],
    ),
    ModuleGroup.parentFinance =>
      const _GroupSpec('Gia đình', 'Tài chính và các yêu cầu với nhà trường', [
        AppModule(
          'Hóa đơn',
          'Khoản cần thanh toán và biên nhận',
          Icons.receipt_long_outlined,
          '/invoices',
        ),
        AppModule(
          'Xin nghỉ học',
          'Tạo, xác nhận và theo dõi đơn',
          Icons.event_busy_outlined,
          '/leave-requests',
          createKind: 'leave',
        ),
        AppModule(
          'Lịch thi',
          'Lịch kiểm tra đã công bố của con',
          Icons.event_note_outlined,
          '/me/exam-agenda',
        ),
        AppModule(
          'Thông báo',
          'Thông tin quan trọng về con',
          Icons.notifications_outlined,
          '/notifications',
        ),
      ]),
  };
}
