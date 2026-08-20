import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class TeachingAssignmentsPage extends StatefulWidget {
  const TeachingAssignmentsPage({super.key});

  @override
  State<TeachingAssignmentsPage> createState() =>
      _TeachingAssignmentsPageState();
}

class _TeachingAssignmentsPageState extends State<TeachingAssignmentsPage> {
  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _workloads = [];
  String? _classFilter;
  String? _semesterFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.classes(),
        _api.semesters(),
        _api.subjects(),
        _api.users(role: 'TEACHER'),
        _api.teachingAssignments(
          classId: _classFilter,
          semesterId: _semesterFilter,
        ),
        _api.teacherWorkloads(semesterId: _semesterFilter),
      ]);
      if (!mounted) return;
      setState(() {
        _classes = values[0];
        _semesters = values[1];
        _subjects = values[2];
        _teachers = values[3]
            .where((teacher) => teacher['status'] == 'ACTIVE')
            .toList();
        _assignments = values[4];
        _workloads = values[5];
      });
    } catch (error) {
      _showError('Không thể tải danh sách phân công. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planned = _assignments.fold<int>(
      0,
      (sum, item) => sum + _int(item['weeklyPeriods']),
    );
    final scheduled = _assignments.fold<int>(
      0,
      (sum, item) => sum + _int(item['scheduledPeriods']),
    );
    final completed = _assignments
        .where((item) => item['fullyScheduled'] == true)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân công giáo viên bộ môn'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: AppColors.adminAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm phân công'),
      ),
      body: Column(
        children: [
          _summary(planned, scheduled, completed),
          _filters(),
          if (!_loading) _teacherOverview(context),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                ? const _EmptyAssignments()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: _assignments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _assignmentCard(_assignments[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summary(int planned, int scheduled, int completed) => Container(
    color: AppColors.adminAccent.withValues(alpha: 0.07),
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        _summaryItem(
          'Phân công',
          '${_assignments.length}',
          Icons.school_outlined,
        ),
        _summaryItem('Tiến độ', '$scheduled/$planned', Icons.schedule_rounded),
        _summaryItem('Đã đủ', '$completed', Icons.check_circle_outline_rounded),
      ],
    ),
  );

  Widget _teacherOverview(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
    color: Theme.of(context).colorScheme.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giáo viên và lớp đang phụ trách',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          'Chạm vào giáo viên để phân công thêm lớp.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 112,
          child: _workloads.isEmpty
              ? const Center(child: Text('Chưa có hồ sơ giáo viên'))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _workloads.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (_, index) {
                    final item = _workloads[index];
                    final classCodes = (item['classCodes'] as List? ?? [])
                        .map((value) => value.toString())
                        .toList();
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () =>
                          _openEditor(null, item['teacherId']?.toString()),
                      child: Container(
                        width: 235,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.adminAccent.withValues(alpha: 0.045),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['teacherName']?.toString() ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['mainSubject']?.toString() ??
                                  'Chưa cập nhật chuyên môn',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              classCodes.isEmpty
                                  ? 'Chưa phụ trách lớp'
                                  : 'Lớp: ${classCodes.join(', ')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.adminAccent,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_int(item['scheduledPeriods'])}/${_int(item['weeklyPeriods'])} tiết/tuần',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );

  Widget _summaryItem(String label, String value, IconData icon) => Expanded(
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.adminAccent),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _filters() => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: ValueKey('class-$_classFilter'),
            initialValue: _classFilter,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Lớp', isDense: true),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Tất cả lớp'),
              ),
              ..._classes.map(
                (item) => DropdownMenuItem<String?>(
                  value: item['id']?.toString(),
                  child: Text(item['code']?.toString() ?? ''),
                ),
              ),
            ],
            onChanged: (value) async {
              _classFilter = value;
              await _load();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: ValueKey('semester-$_semesterFilter'),
            initialValue: _semesterFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Học kỳ',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Tất cả học kỳ'),
              ),
              ..._semesters.map(
                (item) => DropdownMenuItem<String?>(
                  value: item['id']?.toString(),
                  child: Text(item['name']?.toString() ?? ''),
                ),
              ),
            ],
            onChanged: (value) async {
              _semesterFilter = value;
              await _load();
            },
          ),
        ),
      ],
    ),
  );

  Widget _assignmentCard(Map<String, dynamic> item) {
    final planned = _int(item['weeklyPeriods']);
    final scheduled = _int(item['scheduledPeriods']);
    final complete = item['fullyScheduled'] == true;
    final progress = planned == 0 ? 0.0 : (scheduled / planned).clamp(0.0, 1.0);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.adminAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['classCode']?.toString() ?? '',
                    style: const TextStyle(
                      color: AppColors.adminAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item['subjectName']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') _openEditor(item);
                    if (action == 'delete') _delete(item);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa phân công'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item['teacherName']?.toString() ?? '')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: complete
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.adminAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    complete
                        ? 'Đủ tiết lớp này'
                        : 'Còn ${_int(item['remainingPeriods'])} tiết',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: complete
                          ? AppColors.success
                          : AppColors.adminAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              color: complete ? AppColors.success : AppColors.adminAccent,
            ),
            const SizedBox(height: 5),
            Text(
              '$scheduled/$planned tiết mỗi tuần',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Giáo viên đang phụ trách ${_int(item['teacherClassCount'])} lớp · '
              '${_int(item['teacherScheduledPeriods'])}/${_int(item['teacherWeeklyPeriods'])} tiết/tuần',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor([
    Map<String, dynamic>? current,
    String? initialTeacherId,
  ]) async {
    String? classId = current?['classId']?.toString() ?? _classFilter;
    String? semesterId = current?['semesterId']?.toString() ?? _semesterFilter;
    String? subjectId = current?['subjectId']?.toString();
    String? teacherId = current?['teacherId']?.toString() ?? initialTeacherId;
    int weeklyPeriods = _int(current?['weeklyPeriods']);
    if (weeklyPeriods == 0) weeklyPeriods = 2;
    String? formError;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          final selectedSubject = _subjects
              .where((item) => item['id']?.toString() == subjectId)
              .firstOrNull;
          final selectable =
              _teachers
                  .where((teacher) => teacher['status'] == 'ACTIVE')
                  .toList()
                ..sort((left, right) {
                  final specialtyOrder =
                      (_matchesSpecialty(right, selectedSubject) ? 1 : 0) -
                      (_matchesSpecialty(left, selectedSubject) ? 1 : 0);
                  if (specialtyOrder != 0) return specialtyOrder;
                  return (left['fullName']?.toString() ?? '').compareTo(
                    right['fullName']?.toString() ?? '',
                  );
                });
          final selectedWorkload = _workloads
              .where((item) => item['teacherId']?.toString() == teacherId)
              .firstOrNull;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    current == null ? 'Thêm phân công' : 'Cập nhật phân công',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: classId,
                    decoration: const InputDecoration(labelText: 'Lớp học'),
                    items: _classes
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['id']?.toString(),
                            child: Text(item['code']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => classId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: semesterId,
                    decoration: const InputDecoration(labelText: 'Học kỳ'),
                    items: _semesters
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['id']?.toString(),
                            child: Text(item['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => semesterId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: subjectId,
                    decoration: const InputDecoration(labelText: 'Môn học'),
                    items: _subjects
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['id']?.toString(),
                            child: Text(item['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() {
                      subjectId = value;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue:
                        selectable.any(
                          (item) => item['id']?.toString() == teacherId,
                        )
                        ? teacherId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Giáo viên bộ môn',
                    ),
                    items: selectable
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['id']?.toString(),
                            child: Text(
                              '${item['fullName'] ?? ''} · ${item['mainSubject'] ?? 'Chưa cập nhật'}${_matchesSpecialty(item, selectedSubject) ? ' · Phù hợp' : ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => teacherId = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      'Giáo viên phù hợp chuyên môn được ưu tiên; phân công quyết định lớp và môn thực tế phụ trách.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (selectedWorkload != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.adminAccent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_int(selectedWorkload['classCount'])} lớp · ${((selectedWorkload['classCodes'] as List? ?? []).join(', ')).isEmpty ? 'Chưa có lớp' : (selectedWorkload['classCodes'] as List).join(', ')} · ${_int(selectedWorkload['scheduledPeriods'])}/${_int(selectedWorkload['weeklyPeriods'])} tiết/tuần',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: weeklyPeriods.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiết mỗi tuần',
                    ),
                    onChanged: (value) =>
                        weeklyPeriods = int.tryParse(value) ?? 0,
                  ),
                  if (formError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        formError!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      if (classId == null ||
                          semesterId == null ||
                          subjectId == null ||
                          teacherId == null ||
                          weeklyPeriods < 1) {
                        update(
                          () => formError =
                              'Vui lòng nhập đầy đủ thông tin phân công.',
                        );
                        return;
                      }
                      try {
                        final data = {
                          'classId': classId,
                          'semesterId': semesterId,
                          'subjectId': subjectId,
                          'teacherId': teacherId,
                          'weeklyPeriods': weeklyPeriods,
                        };
                        if (current == null) {
                          await _api.createTeachingAssignment(data);
                        } else {
                          await _api.updateTeachingAssignment(
                            current['id'].toString(),
                            data,
                          );
                        }
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext, true);
                        }
                      } catch (error) {
                        update(
                          () => formError = apiErrorMessage(
                            error,
                            fallback:
                                'Không thể lưu phân công. Vui lòng thử lại.',
                          ),
                        );
                      }
                    },
                    child: const Text('Lưu phân công'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phân công?'),
        content: Text(
          '${item['subjectName']} · lớp ${item['classCode']}\nPhải xóa thời khóa biểu liên quan trước.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteTeachingAssignment(item['id'].toString());
      await _load();
    } catch (error) {
      _showError('Không thể xóa phân công. Vui lòng thử lại.');
    }
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  bool _matchesSpecialty(
    Map<String, dynamic> teacher,
    Map<String, dynamic>? subject,
  ) {
    if (subject == null) return false;
    final specialty =
        teacher['mainSubject']?.toString().trim().toLowerCase() ?? '';
    final subjectId = subject['id']?.toString().trim().toLowerCase() ?? '';
    final subjectName = subject['name']?.toString().trim().toLowerCase() ?? '';
    return specialty.isNotEmpty &&
        (specialty == subjectId ||
            specialty == subjectName ||
            (specialty.length >= 3 && subjectName.contains(specialty)) ||
            (subjectName.length >= 3 && specialty.contains(subjectName)));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có phân công giáo viên bộ môn',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Thêm phân công trước khi xếp thời khóa biểu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
