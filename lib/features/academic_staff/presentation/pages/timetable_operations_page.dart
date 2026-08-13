import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/role_page_intro.dart';

/// F05: kiểm tra đầu vào -> xem phương án -> tạo bản nháp -> phát hành.
/// Mobile dùng cùng contract `/timetableSlots/auto-plan` và
/// `/timetable-versions` với Web, không có API dành riêng cho Mobile.
class TimetableOperationsPage extends StatefulWidget {
  const TimetableOperationsPage({super.key});

  @override
  State<TimetableOperationsPage> createState() =>
      _TimetableOperationsPageState();
}

class _TimetableOperationsPageState extends State<TimetableOperationsPage> {
  static const _scopes = <String?, String>{
    null: 'Toàn trường',
    'K10': 'Khối 10',
    'K11': 'Khối 11',
    'K12': 'Khối 12',
  };
  static const _dayNames = <String, String>{
    'MON': 'Thứ Hai',
    'TUE': 'Thứ Ba',
    'WED': 'Thứ Tư',
    'THU': 'Thứ Năm',
    'FRI': 'Thứ Sáu',
    'SAT': 'Thứ Bảy',
    'SUN': 'Chủ nhật',
  };

  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _years = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _requirements = [];
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _teacherLoads = [];
  List<Map<String, dynamic>> _versions = [];
  Map<String, dynamic>? _readiness;
  String? _semesterId;
  String? _scopeGradeLevel;
  Map<String, dynamic>? _plan;
  bool _loading = true;
  bool _checking = false;
  bool _allowPartial = false;
  final Set<String> _allowedDays = {'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.academicYears(),
        _api.semesters(),
        _api.classes(),
      ]);
      _years = values[0];
      _semesters = values[1];
      _classes = values[2];
      final activeYear = _activeYear;
      final activeSemesters =
          _semesters
              .where((item) => item['academicYearId'] == activeYear?['id'])
              .toList()
            ..sort(
              (a, b) => ((a['sequence'] as num?)?.toInt() ?? 0).compareTo(
                (b['sequence'] as num?)?.toInt() ?? 0,
              ),
            );
      if (_semesterId == null ||
          !activeSemesters.any((item) => item['id'] == _semesterId)) {
        _semesterId = activeSemesters.isEmpty
            ? null
            : activeSemesters.first['id']?.toString();
      }
      await _loadSemesterData(showLoader: false);
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể tải dữ liệu xếp lịch.'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic>? get _activeYear {
    for (final item in _years) {
      if (item['status'] == 'ACTIVE') return item;
    }
    return null;
  }

  List<Map<String, dynamic>> get _activeSemesters {
    final yearId = _activeYear?['id'];
    return _semesters.where((item) => item['academicYearId'] == yearId).toList()
      ..sort(
        (a, b) => ((a['sequence'] as num?)?.toInt() ?? 0).compareTo(
          (b['sequence'] as num?)?.toInt() ?? 0,
        ),
      );
  }

  List<Map<String, dynamic>> get _scopedClasses {
    final yearId = _activeYear?['id'];
    return _classes.where((item) {
      return item['academicYearId'] == yearId &&
          (_scopeGradeLevel == null || item['gradeLevel'] == _scopeGradeLevel);
    }).toList();
  }

  List<Map<String, dynamic>> get _scopedAssignments {
    final classIds = _scopedClasses.map((item) => '${item['id']}').toSet();
    return _assignments
        .where((item) => classIds.contains('${item['classId']}'))
        .toList();
  }

  List<String> get _readinessIssues {
    final issues = <String>[];
    final remoteIssues = (_readiness?['issues'] as List? ?? const [])
        .whereType<Map>()
        .where((item) => item['severity'] == 'ERROR')
        .map((item) => '${item['message'] ?? item['code']}')
        .where((message) => message.trim().isNotEmpty);
    issues.addAll(remoteIssues);
    if (_activeYear == null) issues.add('Chưa có năm học đang hoạt động.');
    if (_semesterId == null) issues.add('Chưa có học kỳ để xếp lịch.');
    if (_readiness == null && _scopedClasses.isEmpty) {
      issues.add('${_scopes[_scopeGradeLevel]} chưa có lớp học.');
    }
    if (_readiness == null && _scopedAssignments.isEmpty) {
      issues.add('${_scopes[_scopeGradeLevel]} chưa có phân công giảng dạy.');
    }
    if (_readiness == null && _requirements.isEmpty) {
      issues.add(
        'Chưa có kế hoạch đào tạo. Hãy khai báo số tiết từng môn trước khi tự xếp lịch.',
      );
    }
    return issues.toSet().toList();
  }

  List<String> get _readinessWarnings {
    final warnings = <String>[];
    warnings.addAll(
      (_readiness?['issues'] as List? ?? const [])
          .whereType<Map>()
          .where((item) => item['severity'] == 'WARNING')
          .map((item) => '${item['message'] ?? item['code']}')
          .where((message) => message.trim().isNotEmpty),
    );
    final noRoom = _scopedClasses
        .where((item) => '${item['roomCode'] ?? ''}'.trim().isEmpty)
        .map((item) => '${item['code'] ?? item['name']}')
        .toList();
    if (noRoom.isNotEmpty) {
      warnings.add(
        'Chưa gán phòng cho: ${noRoom.take(4).join(', ')}'
        '${noRoom.length > 4 ? ' và ${noRoom.length - 4} lớp khác' : ''}.',
      );
    }
    final approvedTeachers = _teacherLoads
        .where((item) => const ['APPROVED', 'LOCKED'].contains(item['status']))
        .map((item) => '${item['teacherId']}')
        .toSet();
    final missingLoads = _scopedAssignments
        .where((item) => !approvedTeachers.contains('${item['teacherId']}'))
        .map((item) => '${item['teacherName'] ?? item['teacherId']}')
        .toSet();
    if (missingLoads.isNotEmpty) {
      warnings.add(
        '${missingLoads.length} giáo viên chưa có tải dạy được duyệt.',
      );
    }
    return warnings.toSet().toList();
  }

  Future<void> _loadSemesterData({bool showLoader = true}) async {
    final id = _semesterId;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (showLoader && mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.curriculumRequirements(id),
        _api.teachingAssignments(semesterId: id),
        _api.teacherLoadRegistrations(id),
        _api.timetableVersions(id),
        _api.timetableGenerationReadiness(
          id,
          scopeGradeLevel: _scopeGradeLevel,
          allowedDays: _allowedDays.toList(),
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _requirements = values[0] as List<Map<String, dynamic>>;
        _assignments = values[1] as List<Map<String, dynamic>>;
        _teacherLoads = values[2] as List<Map<String, dynamic>>;
        _versions = values[3] as List<Map<String, dynamic>>;
        _readiness = values[4] as Map<String, dynamic>;
      });
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể kiểm tra dữ liệu học kỳ.'),
        error: true,
      );
    } finally {
      if (showLoader && mounted) setState(() => _loading = false);
    }
  }

  Future<void> _preview() async {
    final id = _semesterId;
    if (id == null || _readinessIssues.isNotEmpty) return;
    setState(() => _checking = true);
    try {
      final plan = await _api.autoPlanTimetable(
        id,
        apply: false,
        allowPartial: _allowPartial,
        scopeGradeLevel: _scopeGradeLevel,
        allowedDays: _allowedDays.toList(),
      );
      if (!mounted) return;
      setState(() => _plan = plan);
      final missing = (plan['unscheduledSlots'] as num?)?.toInt() ?? 0;
      _show(
        missing == 0
            ? 'Phương án đã đủ tiết và không có xung đột.'
            : 'Còn $missing tiết chưa xếp được. Hãy xem các cảnh báo.',
      );
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể tạo phương án thời khóa biểu.'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _applyAndSave() async {
    final semesterId = _semesterId;
    if (semesterId == null || _plan == null) return;
    final unscheduled = (_plan!['unscheduledSlots'] as num?)?.toInt() ?? 0;
    if (unscheduled > 0) {
      _show(
        'Còn $unscheduled tiết chưa xếp được nên chưa thể tạo bản nháp.',
        error: true,
      );
      return;
    }
    final defaultName =
        'TKB ${_scopes[_scopeGradeLevel]} '
        '${DateTime.now().day}/${DateTime.now().month}';
    final name = await _askDraftName(defaultName);
    if (name == null || !mounted) return;
    setState(() => _checking = true);
    try {
      final applied = await _api.autoPlanTimetable(
        semesterId,
        apply: true,
        allowPartial: _allowPartial,
        scopeGradeLevel: _scopeGradeLevel,
        draftName: name,
        allowedDays: _allowedDays.toList(),
      );
      final created = applied['draftVersion'] as Map?;
      if (!mounted) return;
      setState(() => _plan = applied);
      _show(
        'Đã tạo bản nháp “${created?['name'] ?? name}”. Hãy kiểm tra trước khi phát hành.',
      );
      await _loadSemesterData();
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể tạo bản nháp thời khóa biểu.'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<String?> _askDraftName(String initial) async {
    final controller = TextEditingController(text: initial);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tạo bản nháp',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bản nháp chưa hiển thị cho giáo viên và học sinh cho đến khi được phát hành.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 255,
                decoration: const InputDecoration(labelText: 'Tên bản lịch'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) Navigator.pop(context, value);
                  },
                  child: const Text('Tạo bản nháp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _publish(Map<String, dynamic> version) async {
    final confirmed = await _confirm(
      'Phát hành thời khóa biểu?',
      'Giáo viên và học sinh sẽ nhận lịch từ bản “${version['name']}”.',
      'Phát hành',
    );
    if (!confirmed) return;
    setState(() => _checking = true);
    try {
      await _api.publishTimetableVersion('${version['id']}');
      _show('Đã phát hành thời khóa biểu cho giáo viên và học sinh.');
      await _loadSemesterData(showLoader: false);
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể phát hành thời khóa biểu.'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> version) async {
    final confirmed = await _confirm(
      'Xóa bản nháp?',
      'Lịch đang áp dụng không bị thay đổi.',
      'Xóa',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await _api.deleteTimetableVersion('${version['id']}');
      _show('Đã xóa bản nháp.');
      await _loadSemesterData();
    } catch (error) {
      _show(_errorMessage(error, 'Không thể xóa bản nháp.'), error: true);
    }
  }

  Future<void> _viewVersion(Map<String, dynamic> version) async {
    try {
      final slots = await _api.timetableVersionSlots('${version['id']}');
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          maxChildSize: .92,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                '${version['name']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${slots.length} tiết · ${_statusLabel('${version['status']}')}',
              ),
              const SizedBox(height: 12),
              ...slots.map(
                (slot) => Card(
                  child: ListTile(
                    title: Text(
                      '${slot['classCode']} · ${slot['subjectName']}',
                    ),
                    subtitle: Text(
                      '${_dayNames[slot['dayOfWeek']] ?? slot['dayOfWeek']} · '
                      'Tiết ${slot['periodNo']} · ${slot['teacherName']}\n'
                      '${slot['roomCode'] ?? 'Chưa có phòng'}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      _show(
        _errorMessage(error, 'Không thể mở chi tiết bản lịch.'),
        error: true,
      );
    }
  }

  Future<bool> _confirm(
    String title,
    String message,
    String action, {
    bool destructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                    : null,
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final issues = _readinessIssues;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tự xếp thời khóa biểu'),
        actions: [
          IconButton(
            onPressed: _loading || _checking ? null : _bootstrap,
            tooltip: 'Kiểm tra lại dữ liệu',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RolePageIntro(
              title: 'Tạo lịch từ kế hoạch đã chuẩn bị',
              subtitle:
                  'Kiểm tra dữ liệu, xem phương án, tạo bản nháp rồi phát hành.',
              accent: AppColors.adminAccent,
              icon: Icons.auto_awesome_motion_rounded,
            ),
            _stepStrip(),
            const SizedBox(height: 16),
            _configurationCard(),
            const SizedBox(height: 12),
            _readinessCard(issues),
            const SizedBox(height: 12),
            _actionCard(issues),
            if (_plan != null) ...[const SizedBox(height: 12), _planCard()],
            const SizedBox(height: 24),
            _versionHeader(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_versions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Chưa có bản thời khóa biểu nào.'),
                ),
              )
            else
              ..._versions.map(_versionCard),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _stepStrip() {
    const steps = [
      ('1', 'Kiểm tra'),
      ('2', 'Xem trước'),
      ('3', 'Bản nháp'),
      ('4', 'Phát hành'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          children: steps.map((step) {
            return Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.adminAccent.withValues(
                      alpha: .12,
                    ),
                    child: Text(
                      step.$1,
                      style: const TextStyle(
                        color: AppColors.adminAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.$2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _configurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phạm vi xếp lịch',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('semester-$_semesterId'),
              initialValue: _semesterId,
              decoration: const InputDecoration(labelText: 'Học kỳ'),
              items: _activeSemesters
                  .map(
                    (item) => DropdownMenuItem(
                      value: '${item['id']}',
                      child: Text('${item['name'] ?? item['code']}'),
                    ),
                  )
                  .toList(),
              onChanged: _checking
                  ? null
                  : (value) async {
                      setState(() {
                        _semesterId = value;
                        _plan = null;
                      });
                      await _loadSemesterData();
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('scope-$_scopeGradeLevel'),
              initialValue: _scopeGradeLevel,
              decoration: const InputDecoration(labelText: 'Phạm vi'),
              items: _scopes.entries
                  .map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: _checking
                  ? null
                  : (value) async {
                      setState(() {
                        _scopeGradeLevel = value;
                        _plan = null;
                        _readiness = null;
                      });
                      await _loadSemesterData();
                    },
            ),
            const SizedBox(height: 16),
            Text(
              'Ngày được phép xếp lịch',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _dayNames.entries.map((entry) {
                final selected = _allowedDays.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: _checking
                      ? null
                      : (value) async {
                          if (!value && _allowedDays.length == 1) {
                            _show(
                              'Phải giữ ít nhất một ngày để xếp lịch.',
                              error: true,
                            );
                            return;
                          }
                          setState(() {
                            value
                                ? _allowedDays.add(entry.key)
                                : _allowedDays.remove(entry.key);
                            _plan = null;
                            _readiness = null;
                          });
                          await _loadSemesterData();
                        },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readinessCard(List<String> issues) {
    final ready = !_loading && issues.isEmpty;
    final warnings = _readinessWarnings;
    return Card(
      color: ready
          ? Colors.green.withValues(alpha: .08)
          : Theme.of(context).colorScheme.errorContainer.withValues(alpha: .4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ready
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: ready
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ready ? 'Sẵn sàng tạo phương án' : 'Cần hoàn tất dữ liệu',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (ready)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_readiness?['activeClassCount'] ?? _scopedClasses.length} lớp · '
                    '${_readiness?['assignmentCount'] ?? _scopedAssignments.length} phân công · '
                    '${_readiness?['requiredPeriodsPerWeek'] ?? 0} tiết/tuần',
                  ),
                  if ((_readiness?['sourceEducationPlanIds'] as List? ??
                          const [])
                      .isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Nguồn GĐ3: ${(_readiness!['sourceEducationPlanIds'] as List).length} kế hoạch đã công bố',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (warnings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...warnings.map(
                      (warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('Lưu ý: $warning'),
                      ),
                    ),
                  ],
                ],
              )
            else
              ...issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $issue'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(List<String> issues) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              value: _allowPartial,
              onChanged: _checking
                  ? null
                  : (value) => setState(() => _allowPartial = value),
              contentPadding: EdgeInsets.zero,
              title: const Text('Cho phép phương án chưa đủ tiết'),
              subtitle: const Text(
                'Chỉ bật khi cần kiểm tra phần chưa xếp được.',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading || _checking || issues.isNotEmpty
                    ? null
                    : _preview,
                icon: _checking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_checking ? 'Đang xếp lịch…' : 'Tạo phương án'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard() {
    final items = (_plan!['items'] as List? ?? const []);
    final warnings = (_plan!['warnings'] as List? ?? const []);
    final existing = (_plan!['existingSlots'] as num?)?.toInt() ?? 0;
    final proposed = (_plan!['proposedSlots'] as num?)?.toInt() ?? 0;
    final missing = (_plan!['unscheduledSlots'] as num?)?.toInt() ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kết quả phương án',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('$existing tiết hiện có')),
                Chip(label: Text('$proposed tiết đã xếp')),
                Chip(
                  avatar: Icon(
                    missing == 0 ? Icons.check : Icons.warning_rounded,
                    size: 18,
                  ),
                  label: Text('$missing tiết chưa xếp'),
                ),
              ],
            ),
            if (warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...warnings
                  .take(6)
                  .map(
                    (message) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      ),
                      title: Text('$message'),
                    ),
                  ),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Xem các tiết được đề xuất (${items.length})'),
              children: items.take(40).map((raw) {
                final item = Map<String, dynamic>.from(raw as Map);
                final scheduled = item['status'] == 'PROPOSED';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    scheduled
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: scheduled ? Colors.green : AppColors.error,
                  ),
                  title: Text('${item['classCode']} · ${item['subjectName']}'),
                  subtitle: scheduled
                      ? Text(
                          '${_dayNames[item['dayOfWeek']] ?? item['dayOfWeek']} · '
                          'Tiết ${item['periodNo']} · ${item['teacherName']}',
                        )
                      : Text('${item['message']}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _checking || missing > 0 ? null : _applyAndSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Tạo bản nháp từ phương án'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _versionHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Các bản thời khóa biểu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Text('${_versions.length} bản'),
        ],
      ),
    );
  }

  Widget _versionCard(Map<String, dynamic> version) {
    final status = '${version['status']}';
    final publishable = const ['DRAFT', 'VALIDATED'].contains(status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Text('${version['versionNo'] ?? '?'}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${version['name'] ?? 'Bản thời khóa biểu'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${version['scheduledPeriods'] ?? 0} tiết · '
                        '${version['unscheduledPeriods'] ?? 0} chưa xếp',
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(_statusLabel(status))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewVersion(version),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Xem'),
                ),
                if (publishable)
                  IconButton(
                    onPressed: () => _delete(version),
                    tooltip: 'Xóa bản nháp',
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                if (publishable)
                  FilledButton.tonal(
                    onPressed: _checking ? null : () => _publish(version),
                    child: const Text('Phát hành'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String value) =>
      const {
        'DRAFT': 'Bản nháp',
        'VALIDATED': 'Đã kiểm tra',
        'PUBLISHED': 'Đang áp dụng',
        'SUPERSEDED': 'Đã thay thế',
      }[value] ??
      value;

  String _errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'];
        if (message != null && '$message'.trim().isNotEmpty) return '$message';
      }
    }
    return fallback;
  }

  void _show(String text, {bool error = false}) {
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
}
