import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/vi_date_format.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import 'timetable_operations_page.dart';

/// F04 + phần giám sát F06/F07 dành cho Admin.
class AcademicPlanProgressPage extends StatefulWidget {
  const AcademicPlanProgressPage({super.key});

  @override
  State<AcademicPlanProgressPage> createState() =>
      _AcademicPlanProgressPageState();
}

class _AcademicPlanProgressPageState extends State<AcademicPlanProgressPage> {
  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _requirements = [];
  List<Map<String, dynamic>> _progress = [];
  String? _semesterId;
  bool _loading = true;
  StreamSubscription<RealtimeEvent>? _progressEvents;

  @override
  void initState() {
    super.initState();
    _progressEvents = (sl<RealtimeService>()..connect()).events
        .where((event) => event.type == 'TEACHING_PROGRESS_UPDATED')
        .listen((_) => _reloadScope());
    _bootstrap();
  }

  @override
  void dispose() {
    _progressEvents?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.semesters(),
        _api.subjects(),
        _api.classes(),
      ]);
      _semesters = values[0];
      _subjects = values[1];
      _classes = values[2];
      _semesterId ??= _semesters.isEmpty ? null : '${_semesters.first['id']}';
      await _reloadScope();
    } catch (error) {
      _message('Không thể tải kế hoạch. Vui lòng thử lại.', error: true);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadScope() async {
    final id = _semesterId;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.curriculumRequirements(id),
        _api.teachingProgress(semesterId: id),
      ]);
      if (!mounted) return;
      setState(() {
        _requirements = values[0];
        _progress = values[1];
        _loading = false;
      });
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _message('Không thể tải dữ liệu học kỳ. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _editRequirement([Map<String, dynamic>? item]) async {
    if (_semesterId == null || _subjects.isEmpty) return;
    String subjectId = '${item?['subjectId'] ?? _subjects.first['id']}';
    String grade = '${item?['gradeLevel'] ?? '10'}';
    final weekly = TextEditingController(
      text: '${item?['weeklyPeriods'] ?? 3}',
    );
    final total = TextEditingController(text: '${item?['totalPeriods'] ?? 54}');
    final semester = _semesters.firstWhere((s) => '${s['id']}' == _semesterId);
    final start = TextEditingController(
      text: '${item?['startDate'] ?? semester['startDate'] ?? ''}',
    );
    final end = TextEditingController(
      text: '${item?['endDate'] ?? semester['endDate'] ?? ''}',
    );
    final examStart = TextEditingController(
      text: '${item?['examWindowStart'] ?? ''}',
    );
    final examEnd = TextEditingController(
      text: '${item?['examWindowEnd'] ?? ''}',
    );
    final milestone = TextEditingController(
      text: '${item?['milestone'] ?? ''}',
    );
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(
                item == null ? 'Thêm môn vào kế hoạch' : 'Sửa kế hoạch môn',
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: grade,
                              decoration: const InputDecoration(
                                labelText: 'Khối',
                              ),
                              items: ['6', '7', '8', '9', '10', '11', '12']
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text('Khối $v'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setDialogState(() => grade = v!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: subjectId,
                              decoration: const InputDecoration(
                                labelText: 'Môn học',
                              ),
                              items: _subjects
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: '${s['id']}',
                                      child: Text(_name(s)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setDialogState(() => subjectId = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _field(weekly, 'Tiết/tuần', numeric: true),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(total, 'Tổng số tiết', numeric: true),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _field(start, 'Bắt đầu', hint: 'YYYY-MM-DD'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(end, 'Kết thúc', hint: 'YYYY-MM-DD'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _field(examStart, 'Mở cửa sổ thi')),
                          const SizedBox(width: 10),
                          Expanded(child: _field(examEnd, 'Đóng cửa sổ thi')),
                        ],
                      ),
                      TextField(
                        controller: milestone,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Mốc kiến thức bắt buộc',
                          hintText:
                              'Tuần 9 hoàn thành chương 3; tuần 17 ôn tập...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await _api.saveCurriculumRequirement({
        'semesterId': _semesterId,
        'gradeLevel': grade,
        'subjectId': subjectId,
        'weeklyPeriods': int.tryParse(weekly.text) ?? 1,
        'totalPeriods': int.tryParse(total.text),
        'startDate': start.text.trim(),
        'endDate': end.text.trim(),
        'examWindowStart': examStart.text.trim().isEmpty
            ? null
            : examStart.text.trim(),
        'examWindowEnd': examEnd.text.trim().isEmpty
            ? null
            : examEnd.text.trim(),
        'milestone': milestone.text.trim(),
      });
      _message('Đã lưu kế hoạch môn học');
      await _reloadScope();
    } catch (error) {
      _message('Không thể lưu kế hoạch. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _deleteRequirement(String id) async {
    try {
      await _api.deleteCurriculumRequirement(id);
      await _reloadScope();
    } catch (error) {
      _message('Không thể xóa kế hoạch. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _changeRequirementStatus(
    Map<String, dynamic> item,
    String status,
  ) async {
    try {
      await _api.updateCurriculumRequirementStatus(
        '${item['id']}',
        status,
        (item['version'] as num?)?.toInt() ?? 0,
      );
      _message(
        status == 'PUBLISHED'
            ? 'Đã công bố kế hoạch đào tạo'
            : status == 'LOCKED'
            ? 'Đã khóa kế hoạch để rà soát'
            : 'Đã mở lại bản nháp',
      );
      await _reloadScope();
    } catch (error) {
      _message(
        'Không thể đổi trạng thái. Dữ liệu có thể đã được cập nhật, hãy tải lại.',
        error: true,
      );
    }
  }

  Future<void> _reviewMakeup(Map<String, dynamic> item, String status) async {
    final note = TextEditingController();
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              status == 'APPROVED' ? 'Duyệt lịch bù' : 'Từ chối lịch bù',
            ),
            content: TextField(
              controller: note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú cho giáo viên',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Đóng'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await _api.reviewMakeup('${item['id']}', status, note.text.trim());
      _message(
        status == 'APPROVED'
            ? 'Đã duyệt đề xuất. Cần tạo và phát hành bản thời khóa biểu có tiết bù để giáo viên, học sinh và phụ huynh nhìn thấy.'
            : 'Đã từ chối lịch bù',
      );
      await _reloadScope();
      if (status == 'APPROVED' && mounted) {
        final openSchedule =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hoàn tất lịch bù'),
                content: const Text(
                  'Đề xuất đã được duyệt nhưng chưa có buổi học bù trong lịch. '
                  'Hãy mở thời khóa biểu, điều chỉnh bản nháp và phát hành. '
                  'Chỉ sau khi phát hành thì các vai trò liên quan mới nhìn thấy lịch.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Để sau'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Mở thời khóa biểu'),
                  ),
                ],
              ),
            ) ??
            false;
        if (openSchedule && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TimetableOperationsPage()),
          );
        }
      }
    } catch (error) {
      _message('Không thể cập nhật lịch bù. Vui lòng thử lại.', error: true);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool numeric = false,
  }) => TextField(
    controller: controller,
    keyboardType: numeric ? TextInputType.number : null,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch và tiến độ'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Kế hoạch'),
            Tab(text: 'Cân bằng tiến độ'),
            Tab(text: 'Duyệt lịch bù'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: _semesterId,
              decoration: const InputDecoration(labelText: 'Học kỳ làm việc'),
              items: _semesters
                  .map(
                    (s) => DropdownMenuItem(
                      value: '${s['id']}',
                      child: Text(_name(s)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _semesterId = v);
                _reloadScope();
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              children: [
                _PlanList(
                  items: _requirements,
                  onAdd: _editRequirement,
                  onEdit: _editRequirement,
                  onDelete: _deleteRequirement,
                  onStatus: _changeRequirementStatus,
                ),
                _ProgressComparison(
                  items: _progress,
                  classes: _classes,
                  requirements: _requirements,
                ),
                _MakeupReview(items: _progress, onReview: _reviewMakeup),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onStatus,
  });
  final List<Map<String, dynamic>> items;
  final Future<void> Function([Map<String, dynamic>?]) onAdd;
  final Future<void> Function(Map<String, dynamic>) onEdit;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(Map<String, dynamic>, String) onStatus;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const RolePageIntro(
        title: 'Kế hoạch đào tạo',
        subtitle:
            'Mỗi khối/môn chỉ có một kế hoạch trong học kỳ: tổng tiết, thời gian, mốc kiến thức và cửa sổ thi.',
        accent: AppColors.academicStaffAccent,
        icon: Icons.rule_folder_rounded,
      ),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Thêm môn vào kế hoạch'),
      ),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text('Chưa có định mức môn học'),
          ),
        ),
      ...items.map(
        (item) => Card(
          child: ListTile(
            onTap: '${item['planStatus'] ?? 'DRAFT'}' == 'DRAFT'
                ? () => onEdit(item)
                : null,
            leading: CircleAvatar(child: Text('${item['gradeLevel'] ?? '?'}')),
            title: Text('${item['subjectName'] ?? item['subjectId']}'),
            subtitle: Text(
              '${item['weeklyPeriods'] ?? 0} tiết/tuần · ${item['totalPeriods'] ?? 0} tiết\n'
              '${formatViDateRange(item['startDate'], item['endDate'])}\n'
              'Thi: ${formatViDateRange(item['examWindowStart'], item['examWindowEnd'], fallback: 'chưa chốt')}'
              '${('${item['milestone'] ?? ''}').isEmpty ? '' : '\nMốc: ${item['milestone']}'}\n'
              'Trạng thái: ${item['planStatus'] ?? 'DRAFT'} · phiên bản ${item['version'] ?? 0}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit(item);
                  case 'delete':
                    onDelete('${item['id']}');
                  case 'lock':
                    onStatus(item, 'LOCKED');
                  case 'reopen':
                    onStatus(item, 'DRAFT');
                  case 'publish':
                    onStatus(item, 'PUBLISHED');
                }
              },
              itemBuilder: (_) {
                final status = '${item['planStatus'] ?? 'DRAFT'}';
                if (status == 'DRAFT') {
                  return const [
                    PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    PopupMenuItem(
                      value: 'lock',
                      child: Text('Khóa để rà soát'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ];
                }
                if (status == 'LOCKED') {
                  return const [
                    PopupMenuItem(
                      value: 'reopen',
                      child: Text('Mở lại bản nháp'),
                    ),
                    PopupMenuItem(
                      value: 'publish',
                      child: Text('Công bố kế hoạch'),
                    ),
                  ];
                }
                return const [
                  PopupMenuItem(enabled: false, child: Text('Đã công bố')),
                ];
              },
            ),
          ),
        ),
      ),
    ],
  );
}

class _ProgressComparison extends StatelessWidget {
  const _ProgressComparison({
    required this.items,
    required this.classes,
    required this.requirements,
  });

  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> requirements;

  String _grade(Object? value) => '$value'.toUpperCase().replaceFirst('K', '');

  DateTime? _latest(List<Map<String, dynamic>> rows) {
    DateTime? result;
    for (final row in rows) {
      final value = DateTime.tryParse('${row['lessonDate']}');
      if (value != null && (result == null || value.isAfter(result))) {
        result = value;
      }
    }
    return result;
  }

  int _periods(List<Map<String, dynamic>> rows) => rows.fold(
    0,
    (sum, row) => sum + (row['completedPeriods'] as num? ?? 0).toInt(),
  );

  String _date(DateTime? value) => value == null
      ? 'chưa cập nhật'
      : DateFormat('dd/MM/yyyy', 'vi_VN').format(value);

  @override
  Widget build(BuildContext context) {
    final classById = <String, Map<String, dynamic>>{
      for (final schoolClass in classes) '${schoolClass['id']}': schoolClass,
    };
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in items.where((e) => e['status'] == 'COMPLETED')) {
      final schoolClass = classById['${item['classId']}'];
      if (schoolClass == null) continue;
      final key = '${_grade(schoolClass['gradeLevel'])}|${item['subjectId']}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    for (final requirement in requirements) {
      final key =
          '${_grade(requirement['gradeLevel'])}|${requirement['subjectId']}';
      grouped.putIfAbsent(key, () => []);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RolePageIntro(
          title: 'Cân bằng tiến độ',
          subtitle:
              'Hệ thống so cùng khối + cùng môn, cảnh báo khi lệch quá 2 ngày hoặc quá 1 tiết và chỉ rõ lớp cần ưu tiên.',
          accent: AppColors.academicStaffAccent,
          icon: Icons.compare_arrows_rounded,
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ba bước người dùng cần làm',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text('1. Giáo viên xác nhận tiết đã dạy hoặc báo nghỉ.'),
                Text('2. Hệ thống tự tính lớp dẫn trước/lớp chậm.'),
                Text('3. Quản trị viên duyệt lịch bù hoặc yêu cầu điều chỉnh.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (grouped.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Giáo viên chưa cập nhật tiến độ'),
            ),
          ),
        ...grouped.entries.map((entry) {
          final parts = entry.key.split('|');
          final grade = parts.first;
          final subjectId = parts.length > 1 ? parts[1] : '';
          final targetClasses =
              classes
                  .where(
                    (schoolClass) =>
                        _grade(schoolClass['gradeLevel']) == grade &&
                        (schoolClass['studentCount'] as num? ?? 0) > 0,
                  )
                  .toList()
                ..sort((a, b) => '${a['code']}'.compareTo('${b['code']}'));
          final byClass = <String, List<Map<String, dynamic>>>{};
          for (final schoolClass in targetClasses) {
            byClass['${schoolClass['id']}'] = [];
          }
          for (final item in entry.value) {
            byClass.putIfAbsent('${item['classId']}', () => []).add(item);
          }
          final dates = byClass.values
              .map(_latest)
              .whereType<DateTime>()
              .toList();
          final dayGap = dates.length < 2
              ? 0
              : dates
                    .reduce((a, b) => a.isBefore(b) ? a : b)
                    .difference(dates.reduce((a, b) => a.isAfter(b) ? a : b))
                    .inDays
                    .abs();
          final periodValues = byClass.values.map(_periods).toList();
          final maxPeriods = periodValues.isEmpty
              ? 0
              : periodValues.reduce((a, b) => a > b ? a : b);
          final minPeriods = periodValues.isEmpty
              ? 0
              : periodValues.reduce((a, b) => a < b ? a : b);
          final periodGap = maxPeriods - minPeriods;
          final missingClasses = byClass.values
              .where((rows) => rows.isEmpty)
              .length;
          final comparable = byClass.length >= 2;
          final balanced =
              comparable &&
              missingClasses == 0 &&
              dayGap <= 2 &&
              periodGap <= 1;
          final requirement = requirements.where(
            (item) =>
                _grade(item['gradeLevel']) == grade &&
                '${item['subjectId']}' == subjectId,
          );
          final subjectName = entry.value.isNotEmpty
              ? '${entry.value.first['subjectName'] ?? 'Môn học'}'
              : requirement.isNotEmpty
              ? '${requirement.first['subjectName'] ?? 'Môn học'}'
              : 'Môn học';
          return Card(
            child: ExpansionTile(
              leading: Icon(
                balanced ? Icons.check_circle : Icons.warning_amber_rounded,
                color: balanced ? AppColors.success : AppColors.warning,
              ),
              title: Text('Khối $grade · $subjectName'),
              subtitle: Text(
                !comparable
                    ? 'Chưa đủ hai lớp để so sánh'
                    : 'Lệch $dayGap ngày · $periodGap tiết · '
                          '${balanced ? 'Đạt' : 'Cần điều chỉnh'}',
              ),
              children: byClass.entries.map((classEntry) {
                final rows = classEntry.value;
                final periods = _periods(rows);
                rows.sort(
                  (a, b) =>
                      '${b['lessonDate']}'.compareTo('${a['lessonDate']}'),
                );
                final schoolClass = classById[classEntry.key];
                final classCode = schoolClass?['code'] ?? classEntry.key;
                final lag = maxPeriods - periods;
                final latest = _latest(rows);
                final needsAction =
                    comparable &&
                    (rows.isEmpty ||
                        lag > 1 ||
                        (dates.isNotEmpty &&
                            latest != null &&
                            dates
                                    .reduce((a, b) => a.isAfter(b) ? a : b)
                                    .difference(latest)
                                    .inDays >
                                2));
                return ListTile(
                  leading: Icon(
                    needsAction
                        ? Icons.priority_high_rounded
                        : Icons.done_rounded,
                    color: needsAction ? AppColors.warning : AppColors.success,
                  ),
                  title: Text('Lớp $classCode · $periods tiết'),
                  subtitle: Text(
                    rows.isEmpty
                        ? 'Chưa có tiến độ · đề xuất cập nhật ngay'
                        : 'Mới nhất ${_date(latest)} · ${rows.first['topic']}'
                              '${lag > 0 ? '\nĐề xuất tự động: ưu tiên bù $lag tiết trong 2 ngày tới.' : ''}',
                  ),
                  isThreeLine: rows.isNotEmpty && lag > 0,
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}

class _MakeupReview extends StatelessWidget {
  const _MakeupReview({required this.items, required this.onReview});
  final List<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic>, String) onReview;

  @override
  Widget build(BuildContext context) {
    final proposals = items
        .where((e) => e['makeupStatus'] != 'NONE' && e['makeupDate'] != null)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RolePageIntro(
          title: 'Ngoại lệ và lịch bù',
          subtitle:
              'Giáo viên đề xuất ngày bù. Sau khi duyệt, quản trị viên vẫn phải điều chỉnh và phát hành một bản thời khóa biểu mới.',
          accent: AppColors.academicStaffAccent,
          icon: Icons.event_repeat_rounded,
        ),
        if (proposals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Không có đề xuất lịch bù'),
            ),
          ),
        ...proposals.map((item) {
          final pending = item['makeupStatus'] == 'PROPOSED';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['classCode']} · ${item['subjectName']}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nghỉ ${_date(item['lessonDate'])} → đề xuất bù ${_date(item['makeupDate'])}',
                  ),
                  Text('Lý do: ${item['reason'] ?? '—'}'),
                  Text(
                    'Trạng thái: ${_makeupStatusLabel(item['makeupStatus'])}',
                  ),
                  if (item['makeupStatus'] == 'APPROVED')
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Chưa phải lịch đã công bố. Hãy hoàn tất ở màn quản lý thời khóa biểu.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (pending) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => onReview(item, 'REJECTED'),
                            child: const Text('Từ chối'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => onReview(item, 'APPROVED'),
                            child: const Text('Duyệt lịch bù'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

String _name(Map<String, dynamic> item) =>
    '${item['name'] ?? item['code'] ?? 'Chưa đặt tên'}';

String _makeupStatusLabel(Object? value) => switch ('$value') {
  'PROPOSED' => 'Chờ duyệt',
  'APPROVED' => 'Đã duyệt đề xuất · chờ phát hành lịch',
  'REJECTED' => 'Đã từ chối',
  _ => 'Chưa gửi',
};

String _date(dynamic value) {
  final parsed = DateTime.tryParse('$value');
  return parsed == null ? '$value' : DateFormat('dd/MM/yyyy').format(parsed);
}
