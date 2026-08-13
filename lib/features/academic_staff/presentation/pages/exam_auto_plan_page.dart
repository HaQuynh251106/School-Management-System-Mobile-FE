import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/role_page_intro.dart';

/// F08: Mobile chỉ cấu hình và hiển thị phương án; toàn bộ thuật toán và apply
/// nguyên tử chạy tại Backend qua một contract dùng chung với Web.
class ExamAutoPlanPage extends StatefulWidget {
  const ExamAutoPlanPage({super.key});

  @override
  State<ExamAutoPlanPage> createState() => _ExamAutoPlanPageState();
}

class _ExamAutoPlanPageState extends State<ExamAutoPlanPage> {
  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _periods = [];
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _plannedExamSubjects = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _years = [];
  List<Map<String, dynamic>> _semesters = [];
  final Set<String> _selectedSubjects = {};
  List<Map<String, dynamic>> _proposal = [];
  String? _planKey;
  String _startTime = '07:30';
  int _durationMinutes = 90;
  Map<String, List<Map<String, dynamic>>> _savedRooms = {};
  Map<String, List<Map<String, dynamic>>> _savedCandidates = {};
  String? _periodId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Map<String, dynamic> _period(Map<String, dynamic> item) =>
      item['period'] is Map
          ? Map<String, dynamic>.from(item['period'] as Map)
          : item;

  Map<String, dynamic>? get _selectedPeriod {
    for (final item in _periods) {
      final period = _period(item);
      if ('${period['id']}' == _periodId) return period;
    }
    return null;
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.subjects(),
        _api.classes(),
        _api.rooms(),
        _api.users(role: 'TEACHER'),
        _api.academicYears(),
        _api.semesters(),
      ]);
      _subjects = values[0];
      _classes = values[1];
      _rooms = values[2];
      _teachers = values[3];
      _years = values[4];
      _semesters = values[5];
      await _reload();
    } catch (error) {
      _show('Không thể tải dữ liệu kỳ thi. Vui lòng thử lại.', error: true);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      _periods = await _api.examPeriods();
      _periodId ??=
          _periods.isEmpty ? null : '${_period(_periods.first)['id']}';
      await _loadPlannedExamSubjects();
      _schedules =
          _periodId == null ? [] : await _api.examSchedules(_periodId!);
      final roomBatches = await Future.wait(
        _schedules.map((schedule) => _api.examRooms('${schedule['id']}')),
      );
      final candidateBatches = _periodId == null
          ? <List<Map<String, dynamic>>>[]
          : await Future.wait(
              _schedules.map((schedule) =>
                  _api.examCandidates(_periodId!, '${schedule['id']}')),
            );
      _savedRooms = {
        for (var i = 0; i < _schedules.length; i++)
          '${_schedules[i]['id']}': roomBatches[i],
      };
      _savedCandidates = {
        for (var i = 0; i < _schedules.length; i++)
          '${_schedules[i]['id']}': candidateBatches[i],
      };
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _show('Không thể tải kỳ thi. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _loadPlannedExamSubjects() async {
    final period = _selectedPeriod;
    if (period == null) {
      _plannedExamSubjects = [];
      _selectedSubjects.clear();
      return;
    }
    final semesterId = '${period['semesterId'] ?? ''}';
    final grade = '${period['gradeLevel'] ?? ''}'.trim().toUpperCase();
    final periodStart = DateTime.tryParse('${period['startDate'] ?? ''}');
    final periodEnd = DateTime.tryParse('${period['endDate'] ?? ''}');
    if (semesterId.isEmpty || periodStart == null || periodEnd == null) {
      _plannedExamSubjects = [];
      _selectedSubjects.clear();
      return;
    }
    final requirements = await _api.curriculumRequirements(semesterId);
    _plannedExamSubjects = requirements.where((requirement) {
      if ('${requirement['gradeLevel'] ?? ''}'.trim().toUpperCase() != grade) {
        return false;
      }
      final examStart =
          DateTime.tryParse('${requirement['examWindowStart'] ?? ''}');
      final examEnd =
          DateTime.tryParse('${requirement['examWindowEnd'] ?? ''}');
      if (examStart == null || examEnd == null) return false;
      return !periodStart.isBefore(examStart) && !periodEnd.isAfter(examEnd);
    }).toList();
    _selectedSubjects
      ..clear()
      ..addAll(_plannedExamSubjects.map((item) => '${item['subjectId']}'));
  }

  Future<void> _createPeriod() async {
    if (_years.isEmpty || _semesters.isEmpty) return;
    final code = TextEditingController();
    final name = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    String yearId = '${_years.first['id']}';
    String semesterId = '${_semesters.first['id']}';
    String grade = '10';
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('Tạo kỳ thi'),
              content: SizedBox(
                  width: 540,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _field(code, 'Mã kỳ thi', hint: 'HK1-2026'),
                      _field(name, 'Tên kỳ thi', hint: 'Thi học kỳ I'),
                      DropdownButtonFormField<String>(
                        initialValue: yearId,
                        decoration: const InputDecoration(labelText: 'Năm học'),
                        items: _years
                            .map((e) => DropdownMenuItem(
                                value: '${e['id']}', child: Text(_name(e))))
                            .toList(),
                        onChanged: (v) => setDialogState(() => yearId = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: semesterId,
                        decoration: const InputDecoration(labelText: 'Học kỳ'),
                        items: _semesters
                            .map((e) => DropdownMenuItem(
                                value: '${e['id']}', child: Text(_name(e))))
                            .toList(),
                        onChanged: (v) => setDialogState(() => semesterId = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: grade,
                        decoration: const InputDecoration(labelText: 'Khối'),
                        items: ['6', '7', '8', '9', '10', '11', '12']
                            .map((v) => DropdownMenuItem(
                                value: v, child: Text('Khối $v')))
                            .toList(),
                        onChanged: (v) => setDialogState(() => grade = v!),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child:
                                _field(start, 'Từ ngày', hint: 'YYYY-MM-DD')),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(end, 'Đến ngày', hint: 'YYYY-MM-DD')),
                      ]),
                    ]),
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Tạo')),
              ],
            ),
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      final created = await _api.createExamPeriod({
        'code': code.text.trim(),
        'name': name.text.trim(),
        'academicYearId': yearId,
        'semesterId': semesterId,
        'gradeLevel': grade,
        'startDate': start.text.trim(),
        'endDate': end.text.trim(),
      });
      _periodId = '${created['id']}';
      await _reload();
    } catch (error) {
      _show('Không thể tạo kỳ thi. Vui lòng kiểm tra thông tin và thử lại.',
          error: true);
    }
  }

  Widget _field(TextEditingController controller, String label,
          {String? hint}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ));

  Future<void> _buildProposal() async {
    if (_selectedPeriod == null || _periodId == null) return;
    if (_selectedSubjects.isEmpty) {
      return _show('Vui lòng chọn ít nhất một môn thi', error: true);
    }
    setState(() => _loading = true);
    try {
      final preview = await _api.autoPlanExam(
        _periodId!,
        subjectIds: _selectedSubjects.toList()..sort(),
        startTime: _startTime,
        durationMinutes: _durationMinutes,
        apply: false,
        idempotencyKey: _newPlanKey(),
      );
      final schedules = (preview['schedules'] as List? ?? const [])
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
      final blockers = (preview['blockers'] as List? ?? const [])
          .map((value) => '$value')
          .toList();
      setState(() {
        _proposal = schedules;
        _planKey = '${preview['planKey'] ?? ''}';
        _loading = false;
      });
      if (blockers.isNotEmpty) {
        _show(blockers.join('\n'), error: true);
      } else {
        _show(
            'Backend đã kiểm tra ngày nghỉ, cửa sổ thi, phòng, sức chứa, giám thị và người chấm cho ${schedules.length} môn.');
      }
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _show(
          'Backend không thể lập phương án. Vui lòng kiểm tra kế hoạch đào tạo.',
          error: true);
    }
  }

  Future<void> _applyProposal() async {
    if (_periodId == null || _proposal.isEmpty || _planKey == null) return;
    setState(() => _loading = true);
    try {
      final applied = await _api.autoPlanExam(
        _periodId!,
        subjectIds: _selectedSubjects.toList()..sort(),
        startTime: _startTime,
        durationMinutes: _durationMinutes,
        apply: true,
        idempotencyKey: _planKey!,
      );
      final created = (applied['scheduleCount'] as num?)?.toInt() ?? 0;
      _proposal = [];
      _planKey = null;
      _show('Đã lưu nguyên tử $created lịch thi; không có dữ liệu nửa chừng.');
      await _reload();
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _show('Không thể lưu phương án; Backend đã rollback toàn bộ thay đổi.',
          error: true);
    }
  }

  Future<void> _configureRoom(Map<String, dynamic> schedule) async {
    if (_rooms.isEmpty || _teachers.isEmpty) {
      return _show('Cần có phòng và ít nhất 1 giáo viên', error: true);
    }
    List<Map<String, dynamic>> eligibleTeachers;
    try {
      eligibleTeachers = await _api.eligibleExamGraders('${schedule['id']}');
    } catch (_) {
      return _show(
        'Không thể tải danh sách giáo viên phù hợp. Vui lòng thử lại.',
        error: true,
      );
    }
    if (eligibleTeachers.isEmpty) {
      return _show(
        'Không có giáo viên đủ điều kiện và còn trống ở ca thi này.',
        error: true,
      );
    }
    if (!mounted) return;
    String roomId = '${_rooms.first['id']}';
    String proctorOne =
        '${eligibleTeachers.first['teacherId'] ?? eligibleTeachers.first['id']}';
    final classIds =
        (schedule['classIds'] as List? ?? const []).map((e) => '$e').toList();
    String? classId = classIds.isEmpty ? null : classIds.first;
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text('Phòng & giám thị · ${schedule['subjectName']}'),
              content: SizedBox(
                  width: 520,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    DropdownButtonFormField<String>(
                      initialValue: roomId,
                      decoration: const InputDecoration(labelText: 'Phòng thi'),
                      items: _rooms
                          .map((e) => DropdownMenuItem(
                              value: '${e['id']}', child: Text(_name(e))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => roomId = v!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: proctorOne,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Giám thị 1'),
                      items: eligibleTeachers
                          .map((e) => DropdownMenuItem(
                              value: '${e['teacherId'] ?? e['id']}',
                              child: Text(
                                  '${e['teacherName'] ?? e['fullName'] ?? e['teacherId']}')))
                          .toList(),
                      onChanged: (v) => setDialogState(() => proctorOne = v!),
                    ),
                    if (classIds.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: classId,
                        decoration: const InputDecoration(
                            labelText: 'Xếp thí sinh lớp'),
                        items: classIds.map((id) {
                          final found =
                              _classes.where((c) => '${c['id']}' == id);
                          return DropdownMenuItem(
                              value: id,
                              child: Text(
                                  found.isEmpty ? id : _name(found.first)));
                        }).toList(),
                        onChanged: (v) => setDialogState(() => classId = v),
                      ),
                    ],
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Lưu')),
              ],
            ),
          ),
        ) ??
        false;
    if (!ok) return;
    final room = _rooms.firstWhere((e) => '${e['id']}' == roomId);
    try {
      final candidates = _savedCandidates['${schedule['id']}'] ?? const [];
      final existingCandidate = candidates.where(
        (candidate) => '${candidate['classId']}' == classId,
      );
      final existingRoomId = existingCandidate.isEmpty
          ? null
          : '${existingCandidate.first['examRoomId']}';
      final saved = await _api.saveExamRoom('${schedule['id']}', {
        if (existingRoomId != null) 'id': existingRoomId,
        'roomCode': room['code'],
        'capacity': room['capacity'] ?? 45,
        'proctorOneId': proctorOne,
        'proctorTwoId': null,
      });
      if (classId != null) {
        await _api.allocateExamCandidates(
          roomId: '${saved['id']}',
          classId: classId!,
        );
      }
      _show('Đã gán phòng, giám thị và xếp thí sinh');
      await _reload();
    } catch (error) {
      _show('Không thể lưu phòng và giám thị. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _publish() async {
    if (_periodId == null) return;
    try {
      await _api.publishExamSchedule(_periodId!);
      _show('Đã công bố lịch thi');
      await _reload();
    } catch (error) {
      _show('Chưa thể công bố lịch thi. Vui lòng thử lại.', error: true);
    }
  }

  Future<void> _lockScores() async {
    if (_periodId == null) return;
    try {
      await _api.lockExamScores(_periodId!);
      _show('Đã khóa và công bố kết quả thi cho học sinh, phụ huynh');
      await _reload();
    } catch (_) {
      _show('Chưa thể khóa điểm. Hãy bảo đảm mọi thí sinh đã có điểm.',
          error: true);
    }
  }

  Future<void> _confirmPeriod() async {
    if (_periodId == null) return;
    try {
      await _api.confirmExamPeriod(_periodId!);
      _show('Đã xác nhận kỳ thi');
      await _reload();
    } catch (_) {
      _show('Chỉ có thể xác nhận sau khi đã khóa điểm.', error: true);
    }
  }

  void _show(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : null));
  }

  String _newPlanKey() =>
      'mobile-${DateTime.now().microsecondsSinceEpoch}-${_selectedSubjects.length}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tự xếp lịch thi')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const RolePageIntro(
            title: 'Lập phương án lịch thi',
            subtitle:
                'Hệ thống tự rải môn, xếp phòng, giám thị, thí sinh và người chấm. Bạn chỉ kiểm tra, điều chỉnh ngoại lệ rồi công bố.',
            accent: AppColors.academicStaffAccent,
            icon: Icons.event_available_rounded,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('5 bước người dùng cần làm',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Text('1. Chọn hoặc tạo kỳ thi và khoảng ngày thi.'),
                  const Text('2. Kiểm tra danh sách môn thi cố định.'),
                  const Text('3. Chọn Xem phương án để hệ thống tự xếp.'),
                  const Text('4. Chỉ sửa phòng/giám thị khi có ngoại lệ.'),
                  const Text('5. Bấm Công bố để gửi lịch cho các vai trò.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: DropdownButtonFormField<String>(
              initialValue: _periodId,
              decoration: const InputDecoration(labelText: 'Kỳ thi'),
              items: _periods.map((e) {
                final p = _period(e);
                return DropdownMenuItem(
                    value: '${p['id']}', child: Text(_name(p)));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _periodId = v;
                  _proposal = [];
                });
                _reload();
              },
            )),
            const SizedBox(width: 10),
            IconButton.filledTonal(
                onPressed: _createPeriod,
                tooltip: 'Tạo kỳ thi',
                icon: const Icon(Icons.add_rounded)),
          ]),
          if (_loading)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator()),
          const SizedBox(height: 12),
          Text('Môn thi cố định',
              style: Theme.of(context).textTheme.titleMedium),
          const Text(
            'Danh sách lấy từ cửa sổ thi trong Kế hoạch đào tạo. Muốn đổi môn, '
            'hãy cập nhật kế hoạch trước khi xếp lịch.',
          ),
          const SizedBox(height: 7),
          if (_plannedExamSubjects.isEmpty)
            const Card(
              child: ListTile(
                leading:
                    Icon(Icons.info_outline_rounded, color: AppColors.warning),
                title: Text('Chưa có môn thi hợp lệ'),
                subtitle: Text(
                    'Hãy khai báo cửa sổ thi cho môn và khối trong Kế hoạch đào tạo.'),
              ),
            )
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _plannedExamSubjects.map((requirement) {
                final subjectId = '${requirement['subjectId']}';
                final subject =
                    _subjects.cast<Map<String, dynamic>?>().firstWhere(
                          (item) => '${item?['id']}' == subjectId,
                          orElse: () => null,
                        );
                return Chip(
                  avatar: const Icon(Icons.lock_outline_rounded, size: 17),
                  label: Text(subject == null
                      ? '${requirement['subjectName'] ?? subjectId}'
                      : _name(subject)),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final parts = _startTime.split(':');
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.tryParse(parts.first) ?? 7,
                      minute: int.tryParse(parts.last) ?? 30,
                    ),
                  );
                  if (time != null && mounted) {
                    setState(() {
                      _startTime =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      _proposal = [];
                      _planKey = null;
                    });
                  }
                },
                icon: const Icon(Icons.schedule_rounded),
                label: Text('Bắt đầu $_startTime'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _durationMinutes,
                decoration: const InputDecoration(labelText: 'Thời lượng'),
                items: const [45, 60, 90, 120, 150, 180]
                    .map((minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text('$minutes phút'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _durationMinutes = value ?? 90;
                  _proposal = [];
                  _planKey = null;
                }),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _periodId == null ? null : _buildProposal,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Xem phương án'))),
            const SizedBox(width: 10),
            Expanded(
                child: FilledButton.icon(
                    onPressed: _proposal.isEmpty ? null : _applyProposal,
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Lưu phương án'))),
          ]),
          if (_proposal.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._proposal.map((e) {
              final allocations = (e['allocations'] as List? ?? const [])
                  .map((value) => Map<String, dynamic>.from(value as Map))
                  .toList();
              return Card(
                  child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e['subjectName']}',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                          '${e['examDate']} · ${e['startTime']} · ${e['durationMinutes']} phút'),
                      const SizedBox(height: 6),
                      ...allocations.map((a) => Text(
                          '${a['classCode']} → ${a['roomCode']} · ${a['proctorName']} · ${a['studentCount']} HS')),
                    ]),
              ));
            }),
          ],
          const Divider(height: 32),
          Row(children: [
            Expanded(
                child: Text('Lịch đã lưu (${_schedules.length})',
                    style: Theme.of(context).textTheme.titleMedium)),
            FilledButton.tonalIcon(
                onPressed: _schedules.isEmpty ? null : _publish,
                icon: const Icon(Icons.publish_rounded),
                label: const Text('Công bố')),
          ]),
          if (_selectedPeriod != null &&
              _selectedPeriod!['schedulePublished'] == true) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectedPeriod!['scoreEntryLocked'] == true
                      ? null
                      : _lockScores,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Khóa & công bố điểm'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _selectedPeriod!['scoreEntryLocked'] == true &&
                          '${_selectedPeriod!['status']}' != 'CONFIRMED'
                      ? _confirmPeriod
                      : null,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Xác nhận kỳ thi'),
                ),
              ),
            ]),
          ],
          ..._schedules.map((schedule) {
            final rooms = _savedRooms['${schedule['id']}'] ?? const [];
            final roomSummary = rooms.isEmpty
                ? 'Chưa phân phòng'
                : rooms
                    .map((room) =>
                        '${room['roomCode']} · ${room['proctorOneName'] ?? 'chưa có giám thị'}')
                    .join('\n');
            return Card(
                child: ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.event_note_rounded)),
              title: Text('${schedule['subjectName']}'),
              subtitle: Text(
                  '${schedule['examDate']} · ${schedule['startTime']} · '
                  '${schedule['durationMinutes']} phút · ${(schedule['classIds'] as List? ?? const []).length} lớp\n$roomSummary'),
              isThreeLine: true,
              trailing: IconButton(
                  tooltip: 'Phòng và giám thị',
                  onPressed: () => _configureRoom(schedule),
                  icon: const Icon(Icons.meeting_room_outlined)),
            ));
          }),
        ]),
      );
}

String _name(Map<String, dynamic> item) =>
    '${item['name'] ?? item['fullName'] ?? item['code'] ?? 'Chưa đặt tên'}';
String _iso(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
