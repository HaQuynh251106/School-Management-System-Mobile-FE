import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AcademicStaffHome extends StatefulWidget {
  const AcademicStaffHome({super.key});

  @override
  State<AcademicStaffHome> createState() => _AcademicStaffHomeState();
}

class _AcademicStaffHomeState extends State<AcademicStaffHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => AdaptiveRoleScaffold(
        index: _tab,
        onSelected: (value) => setState(() => _tab = value),
        accent: AppColors.academicStaffAccent,
        pages: const [
          _AcademicOverview(),
          _StructurePage(),
          _TimetableVersionsPage(),
          _ExamPeriodsPage(),
          _AcademicAccountPage(),
        ],
        destinations: const [
          RoleDestination(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              label: 'Tổng quan'),
          RoleDestination(
              icon: Icons.account_tree_outlined,
              selectedIcon: Icons.account_tree_rounded,
              label: 'Cơ cấu'),
          RoleDestination(
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              label: 'Xếp lịch'),
          RoleDestination(
              icon: Icons.event_note_outlined,
              selectedIcon: Icons.event_note_rounded,
              label: 'Kỳ thi'),
          RoleDestination(
              icon: Icons.person_outline,
              selectedIcon: Icons.person_rounded,
              label: 'Tôi'),
        ],
      );
}

class _AcademicSnapshot {
  const _AcademicSnapshot(
      this.years, this.semesters, this.classes, this.subjects);
  final List<Map<String, dynamic>> years;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> subjects;
}

Future<_AcademicSnapshot> _loadSnapshot() async {
  final api = sl<ApiService>();
  final values = await Future.wait([
    api.academicYears(),
    api.semesters(),
    api.classes(),
    api.subjects(),
  ]);
  return _AcademicSnapshot(values[0], values[1], values[2], values[3]);
}

class _AcademicOverview extends StatelessWidget {
  const _AcademicOverview();

  @override
  Widget build(BuildContext context) => _AsyncScaffold<_AcademicSnapshot>(
        title: 'Điều hành học vụ',
        load: _loadSnapshot,
        builder: (context, data, reload) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RolePageIntro(
              title: 'Trung tâm Giáo vụ',
              subtitle:
                  'Theo dõi cơ cấu đào tạo, tiến độ xếp lịch và kỳ thi trong một nơi.',
              accent: AppColors.academicStaffAccent,
              icon: Icons.school_rounded,
              badges: ['Dữ liệu trực tiếp', 'Theo đúng phân quyền'],
            ),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _Metric('Năm học', data.years.length, Icons.date_range_rounded),
                _Metric(
                    'Học kỳ', data.semesters.length, Icons.view_week_rounded),
                _Metric('Lớp học', data.classes.length, Icons.groups_rounded),
                _Metric(
                    'Môn học', data.subjects.length, Icons.menu_book_rounded),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Việc cần kiểm tra', Icons.fact_check_outlined),
            const SizedBox(height: 8),
            const _InfoCard(
              icon: Icons.calendar_month_rounded,
              title: 'Phiên bản thời khóa biểu',
              subtitle:
                  'Lưu bản nháp, kiểm tra rồi phát hành để giáo viên và học sinh chỉ thấy lịch chính thức.',
            ),
            const _InfoCard(
              icon: Icons.event_available_rounded,
              title: 'Kỳ thi và lịch thi',
              subtitle:
                  'Theo dõi trạng thái kỳ thi trước khi công bố cho toàn trường.',
            ),
          ],
        ),
      );
}

class _StructurePage extends StatelessWidget {
  const _StructurePage();

  @override
  Widget build(BuildContext context) => _AsyncScaffold<_AcademicSnapshot>(
        title: 'Cơ cấu đào tạo',
        load: _loadSnapshot,
        builder: (context, data, reload) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RolePageIntro(
              title: 'Cơ cấu năm học',
              subtitle:
                  'Quan sát nhanh lớp, ca học, phòng và năm học đang áp dụng.',
              accent: AppColors.academicStaffAccent,
              icon: Icons.account_tree_rounded,
            ),
            const _SectionTitle('Năm học và học kỳ', Icons.date_range_rounded),
            ...data.years.map((year) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Icons.calendar_today_rounded)),
                    title:
                        Text((year['name'] ?? year['code'] ?? '').toString()),
                    subtitle: Text(
                        '${year['startDate'] ?? ''} → ${year['endDate'] ?? ''}'),
                    trailing: _StatusChip((year['status'] ?? '').toString()),
                  ),
                )),
            const SizedBox(height: 18),
            _SectionTitle(
                'Danh sách lớp (${data.classes.length})', Icons.groups_rounded),
            ...data.classes.map((classroom) => Card(
                  child: ListTile(
                    leading:
                        const CircleAvatar(child: Icon(Icons.school_outlined)),
                    title: Text((classroom['name'] ?? classroom['code'] ?? '')
                        .toString()),
                    subtitle: Text(
                        '${classroom['gradeLevel'] ?? ''} • ${_shift(classroom['studyShift'])} • Phòng ${classroom['roomCode'] ?? 'chưa xếp'}'),
                    trailing: Text(
                        (classroom['homeroomTeacherName'] ?? 'Chưa có GVCN')
                            .toString(),
                        textAlign: TextAlign.end),
                  ),
                )),
          ],
        ),
      );
}

class _TimetableVersionsPage extends StatefulWidget {
  const _TimetableVersionsPage();

  @override
  State<_TimetableVersionsPage> createState() => _TimetableVersionsPageState();
}

class _TimetableVersionsPageState extends State<_TimetableVersionsPage> {
  final Future<List<Map<String, dynamic>>> _semesters =
      sl<ApiService>().semesters();
  String? _selected;
  Future<List<Map<String, dynamic>>>? _versions;

  void _select(String id) {
    _selected = id;
    _versions = sl<ApiService>().timetableVersions(id);
  }

  void _reload() => setState(() {
        if (_selected != null) {
          _versions = sl<ApiService>().timetableVersions(_selected!);
        }
      });

  Future<void> _createDraft() async {
    if (_selected == null) return;
    final controller = TextEditingController(
        text: 'Lịch dự kiến ${DateTime.now().day}/${DateTime.now().month}');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu phiên bản nháp'),
        content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Tên phiên bản')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Lưu bản nháp')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await sl<ApiService>().createTimetableVersion(_selected!, name);
    _reload();
  }

  Future<void> _publish(String id) async {
    await sl<ApiService>().publishTimetableVersion(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã phát hành thời khóa biểu')));
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Phiên bản thời khóa biểu')),
        floatingActionButton: _selected == null
            ? null
            : FloatingActionButton.extended(
                onPressed: _createDraft,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Lưu bản nháp')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _semesters,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final semesters = snapshot.data!;
            if (_selected == null && semesters.isNotEmpty) {
              _select(semesters.first['id'].toString());
            }
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selected,
                  decoration:
                      const InputDecoration(labelText: 'Học kỳ đang làm việc'),
                  items: semesters
                      .map((item) => DropdownMenuItem(
                          value: item['id'].toString(),
                          child:
                              Text((item['name'] ?? item['code']).toString())))
                      .toList(),
                  onChanged: (value) => setState(() {
                    if (value != null) _select(value);
                  }),
                ),
              ),
              Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _versions,
                builder: (context, versionSnapshot) {
                  if (!versionSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final versions = versionSnapshot.data!;
                  if (versions.isEmpty) {
                    return const Center(
                        child: Text(
                            'Chưa có phiên bản. Hãy lưu lịch hiện tại thành bản nháp.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: versions.length,
                      itemBuilder: (context, index) {
                        final version = versions[index];
                        final status = (version['status'] ?? '').toString();
                        return Card(
                            child: ListTile(
                          leading: CircleAvatar(
                              child: Text(
                                  'v${version['versionNo'] ?? index + 1}')),
                          title: Text(
                              (version['name'] ?? 'Phiên bản lịch').toString()),
                          subtitle: Text(
                              '${version['scheduledPeriods'] ?? 0} tiết đã xếp • ${version['unscheduledPeriods'] ?? 0} tiết lỗi'),
                          trailing: status == 'DRAFT'
                              ? FilledButton.tonal(
                                  onPressed: () =>
                                      _publish(version['id'].toString()),
                                  child: const Text('Phát hành'))
                              : _StatusChip(status),
                        ));
                      },
                    ),
                  );
                },
              )),
            ]);
          },
        ),
      );
}

class _ExamPeriodsPage extends StatelessWidget {
  const _ExamPeriodsPage();

  @override
  Widget build(BuildContext context) =>
      _AsyncScaffold<List<Map<String, dynamic>>>(
        title: 'Kỳ thi',
        load: sl<ApiService>().examPeriods,
        builder: (context, items, reload) => RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const RolePageIntro(
                  title: 'Tổ chức kỳ thi',
                  subtitle:
                      'Theo dõi thời gian, phạm vi và trạng thái công bố lịch thi.',
                  accent: AppColors.academicStaffAccent,
                  icon: Icons.event_note_rounded),
              if (items.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Chưa có kỳ thi'))),
              ...items.map((item) => Card(
                      child: ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Icons.fact_check_outlined)),
                    title:
                        Text((item['name'] ?? item['code'] ?? '').toString()),
                    subtitle: Text(
                        '${item['startDate'] ?? ''} → ${item['endDate'] ?? ''} • Khối ${item['gradeLevel'] ?? 'toàn trường'}'),
                    trailing: _StatusChip((item['status'] ?? '').toString()),
                  ))),
            ],
          ),
        ),
      );
}

class _AcademicAccountPage extends StatelessWidget {
  const _AcademicAccountPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản Giáo vụ')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const RolePageIntro(
            title: 'Hồ sơ công việc',
            subtitle:
                'Tài khoản chuyên trách cơ cấu đào tạo, thời khóa biểu và kỳ thi.',
            accent: AppColors.academicStaffAccent,
            icon: Icons.badge_rounded),
        Card(
            child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user?.fullName ?? ''),
                subtitle: Text('@${user?.username ?? ''}'))),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Đăng xuất'),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ),
      ]),
    );
  }
}

class _AsyncScaffold<T> extends StatefulWidget {
  const _AsyncScaffold(
      {required this.title, required this.load, required this.builder});
  final String title;
  final Future<T> Function() load;
  final Widget Function(BuildContext, T, Future<void> Function()) builder;

  @override
  State<_AsyncScaffold<T>> createState() => _AsyncScaffoldState<T>();
}

class _AsyncScaffoldState<T> extends State<_AsyncScaffold<T>> {
  late Future<T> _future = widget.load();
  Future<void> _reload() async {
    setState(() {
      _future = widget.load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: FutureBuilder<T>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('Không thể tải dữ liệu: ${snapshot.error}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                              onPressed: _reload, child: const Text('Thử lại'))
                        ])));
              }
              return widget.builder(context, snapshot.data as T, _reload);
            }),
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.academicStaffAccent),
            const Spacer(),
            Text('$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(label)
          ])));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: AppColors.academicStaffAccent),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800))
      ]);
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title),
          subtitle: Text(subtitle)));
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'PUBLISHED' => 'Đã phát hành',
      'ACTIVE' => 'Đang hoạt động',
      'PLANNED' => 'Sắp diễn ra',
      'DRAFT' => 'Bản nháp',
      'CONFIRMED' => 'Đã xác nhận',
      _ => status
    };
    return Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact);
  }
}

String _shift(dynamic value) => switch (value?.toString()) {
      'MORNING' => 'Ca sáng',
      'AFTERNOON' => 'Ca chiều',
      _ => value?.toString() ?? 'Chưa chọn ca'
    };
