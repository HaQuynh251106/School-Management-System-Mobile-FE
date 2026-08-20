import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import 'exam_auto_plan_page.dart';

class ExamManagementPage extends StatefulWidget {
  const ExamManagementPage({super.key});

  @override
  State<ExamManagementPage> createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends State<ExamManagementPage> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _api.examPeriods();

  Future<void> _reload() async {
    final future = _api.examPeriods();
    setState(() => _future = future);
    await future;
  }

  Future<void> _create() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _PeriodForm(),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kỳ thi'),
      actions: [
        IconButton(
          tooltip: 'Tự xếp lịch thi',
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ExamAutoPlanPage()));
            await _reload();
          },
          icon: const Icon(Icons.auto_awesome_rounded),
        ),
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tạo kỳ thi'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(error: snapshot.error, retry: _reload);
        }
        final items = snapshot.data ?? const [];
        return RefreshIndicator(
          onRefresh: _reload,
          child: items.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(32),
                  children: const [
                    SizedBox(height: 96),
                    Icon(Icons.event_note_outlined, size: 56),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có kỳ thi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tạo kỳ thi để bắt đầu xếp lịch và phòng thi.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final summary = items[index];
                    final period = Map<String, dynamic>.from(
                      summary['period'] as Map? ?? summary,
                    );
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.fact_check_outlined),
                        ),
                        title: Text(
                          (period['name'] ?? period['code']).toString(),
                        ),
                        subtitle: Text(
                          '${_formatExamDate(period['startDate'])} - ${_formatExamDate(period['endDate'])}\n'
                          '${summary['scheduleCount'] ?? 0} lịch • '
                          '${summary['candidateCount'] ?? 0} thí sinh • '
                          '${summary['pendingReviewCount'] ?? 0} phúc khảo',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _PeriodDetail(
                                period: period,
                                summary: summary,
                              ),
                            ),
                          );
                          await _reload();
                        },
                      ),
                    );
                  },
                ),
        );
      },
    ),
  );
}

class _PeriodDetail extends StatefulWidget {
  const _PeriodDetail({required this.period, required this.summary});
  final Map<String, dynamic> period;
  final Map<String, dynamic> summary;

  @override
  State<_PeriodDetail> createState() => _PeriodDetailState();
}

class _PeriodDetailState extends State<_PeriodDetail> {
  final _api = sl<ApiService>();
  late Map<String, dynamic> _period = {...widget.period};
  late Future<List<Map<String, dynamic>>> _future = _api.examSchedules(
    _period['id'].toString(),
  );
  bool _publishing = false;
  bool _changingState = false;

  Future<void> _reload() async {
    final future = _api.examSchedules(_period['id'].toString());
    setState(() => _future = future);
    await future;
  }

  Future<void> _addSchedule() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ScheduleForm(
        periodId: _period['id'].toString(),
        start: DateTime.parse(_period['startDate'].toString()),
        end: DateTime.parse(_period['endDate'].toString()),
      ),
    );
    if (saved == true) await _reload();
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    try {
      final value = await _api.publishExamSchedule(_period['id'].toString());
      if (!mounted) return;
      setState(() => _period = value);
      _message('Đã phát hành lịch thi.');
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback:
                'Chưa thể phát hành. Hãy kiểm tra phòng, thí sinh và giám thị.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _changeScoreState(String action) async {
    setState(() => _changingState = true);
    try {
      final id = _period['id'].toString();
      final value = switch (action) {
        'LOCK' => await _api.lockExamScores(id),
        'UNLOCK' => await _api.unlockExamScores(id),
        _ => await _api.confirmExamPeriod(id),
      };
      if (!mounted) return;
      setState(() => _period = value);
      _message(switch (action) {
        'LOCK' => 'Đã khóa và công bố điểm thi.',
        'UNLOCK' => 'Đã mở khóa để giáo viên sửa điểm.',
        _ => 'Đã xác nhận hoàn tất kỳ thi.',
      });
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback: 'Không thể cập nhật trạng thái kỳ thi. Vui lòng thử lại.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _changingState = false);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final published = _period['schedulePublished'] == true;
    final scoreLocked = _period['scoreEntryLocked'] == true;
    final confirmed = _period['status'] == 'CONFIRMED';
    return Scaffold(
      appBar: AppBar(title: Text(_period['name'].toString())),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSchedule,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm lịch'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _period['code'].toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_formatExamDate(_period['startDate'])} - ${_formatExamDate(_period['endDate'])}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Count(widget.summary['scheduleCount'], 'Lịch'),
                      _Count(widget.summary['roomCount'], 'Phòng'),
                      _Count(widget.summary['candidateCount'], 'Thí sinh'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: published || _publishing ? null : _publish,
            icon: Icon(
              published ? Icons.check_circle_rounded : Icons.publish_rounded,
            ),
            label: Text(
              published
                  ? 'Lịch đã phát hành'
                  : _publishing
                  ? 'Đang phát hành...'
                  : 'Phát hành lịch thi',
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hoàn tất chấm thi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    confirmed
                        ? 'Kỳ thi đã xác nhận hoàn tất.'
                        : scoreLocked
                        ? 'Điểm đã công bố. Có thể mở khóa để sửa hoặc xác nhận hoàn tất.'
                        : 'Sau khi giáo viên nhập đủ điểm, khóa điểm để công bố cho học sinh.',
                  ),
                  const SizedBox(height: 12),
                  if (!confirmed && !scoreLocked)
                    FilledButton.icon(
                      onPressed: published && !_changingState
                          ? () => _changeScoreState('LOCK')
                          : null,
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('Khóa và công bố điểm'),
                    ),
                  if (!confirmed && scoreLocked) ...[
                    FilledButton.icon(
                      onPressed: _changingState
                          ? null
                          : () => _changeScoreState('CONFIRM'),
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('Xác nhận hoàn tất kỳ thi'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _changingState
                          ? null
                          : () => _changeScoreState('UNLOCK'),
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Mở khóa để sửa điểm'),
                    ),
                  ],
                  if (confirmed)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                      title: Text('Đã hoàn tất'),
                      subtitle: Text(
                        'Bảng điểm được giữ ổn định; thay đổi tiếp theo đi qua phúc khảo.',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Lịch thi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _ErrorView(error: snapshot.error, retry: _reload);
              }
              final schedules = snapshot.data ?? const [];
              if (schedules.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Chưa có lịch thi. Chọn “Thêm lịch” để bắt đầu.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Column(
                children: schedules.map((item) {
                  final classes = item['classIds'] as List? ?? const [];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(item['subjectName'].toString()),
                      subtitle: Text(
                        '${item['examDate']} • ${item['startTime']} • '
                        '${item['durationMinutes']} phút\n${classes.length} lớp',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _SchedulePreparation(schedule: item),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _formatExamDate(dynamic value) {
  final date = value is DateTime
      ? value
      : DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'Chưa xác định';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class _SchedulePreparation extends StatefulWidget {
  const _SchedulePreparation({required this.schedule});
  final Map<String, dynamic> schedule;

  @override
  State<_SchedulePreparation> createState() => _SchedulePreparationState();
}

class _SchedulePreparationState extends State<_SchedulePreparation> {
  final _api = sl<ApiService>();
  late Future<List<Object>> _future = _load();

  Future<List<Object>> _load() => Future.wait<Object>([
    _api.examRooms(widget.schedule['id'].toString()),
    _api.examGraders(widget.schedule['id'].toString()),
    _api.eligibleExamGraders(widget.schedule['id'].toString()),
    _api.rooms(),
    _api.users(role: 'TEACHER'),
    _api.classes(),
  ]);

  Future<void> _reload() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _addRoom(List<Object> data) async {
    final rooms = data[3] as List<Map<String, dynamic>>;
    final teachers = data[4] as List<Map<String, dynamic>>;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RoomForm(
        scheduleId: widget.schedule['id'].toString(),
        rooms: rooms,
        teachers: teachers,
      ),
    );
    if (saved == true) await _reload();
  }

  Future<void> _allocate(
    Map<String, dynamic> room,
    List<Map<String, dynamic>> classes,
  ) async {
    final allowed = (widget.schedule['classIds'] as List? ?? const [])
        .map((id) => id.toString())
        .toSet();
    final available = classes
        .where((item) => allowed.contains(item['id']))
        .toList();
    final classId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Chọn lớp để xếp phòng'),
        children: available
            .map(
              (item) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, item['id'].toString()),
                child: Text((item['name'] ?? item['code']).toString()),
              ),
            )
            .toList(),
      ),
    );
    if (classId == null) return;
    try {
      final candidates = await _api.allocateExamCandidates(
        roomId: room['id'].toString(),
        classId: classId,
      );
      if (mounted) _message('Đã xếp ${candidates.length} thí sinh vào phòng.');
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback: 'Không thể xếp thí sinh. Vui lòng thử lại.',
          ),
        );
      }
    }
  }

  Future<void> _assignGrader(
    List<Map<String, dynamic>> eligible,
    List<Map<String, dynamic>> classes,
  ) async {
    final allowed = (widget.schedule['classIds'] as List? ?? const [])
        .map((id) => id.toString())
        .toSet();
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      useSafeArea: true,
      builder: (_) => _GraderForm(
        teachers: eligible,
        classes: classes.where((item) => allowed.contains(item['id'])).toList(),
      ),
    );
    if (selected == null) return;
    try {
      await _api.saveExamGrader(
        scheduleId: widget.schedule['id'].toString(),
        classId: selected['classId']!,
        teacherId: selected['teacherId']!,
      );
      await _reload();
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback:
                'Không thể phân công giáo viên chấm thi. Vui lòng thử lại.',
          ),
        );
      }
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.schedule['subjectName'].toString())),
    body: FutureBuilder<List<Object>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(error: snapshot.error, retry: _reload);
        }
        final rooms = snapshot.data![0] as List<Map<String, dynamic>>;
        final graders = snapshot.data![1] as List<Map<String, dynamic>>;
        final eligible = snapshot.data![2] as List<Map<String, dynamic>>;
        final classes = snapshot.data![5] as List<Map<String, dynamic>>;
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text(
                    '${widget.schedule['examDate']} • ${widget.schedule['startTime']}',
                  ),
                  subtitle: Text('${widget.schedule['durationMinutes']} phút'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Phòng thi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Thêm phòng thi',
                    onPressed: () => _addRoom(snapshot.data!),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              if (rooms.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Chưa có phòng thi.'),
                  ),
                ),
              ...rooms.map(
                (room) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room_outlined),
                    title: Text(room['roomCode'].toString()),
                    subtitle: Text(
                      'Sức chứa ${room['capacity']} • '
                      '${room['proctorOneName'] ?? 'Chưa có giám thị'}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Xếp thí sinh',
                      onPressed: () => _allocate(room, classes),
                      icon: const Icon(Icons.groups_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Phân công chấm',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Phân công giáo viên',
                    onPressed: eligible.isEmpty
                        ? null
                        : () => _assignGrader(eligible, classes),
                    icon: const Icon(Icons.person_add_alt_rounded),
                  ),
                ],
              ),
              if (eligible.isEmpty && graders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Chưa có giáo viên đủ điều kiện cho môn thi.'),
                  ),
                ),
              ...graders.map(
                (grader) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_ind_outlined),
                    title: Text(grader['teacherName'].toString()),
                    subtitle: Text('Lớp ${grader['classCode']}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _RoomForm extends StatefulWidget {
  const _RoomForm({
    required this.scheduleId,
    required this.rooms,
    required this.teachers,
  });
  final String scheduleId;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> teachers;

  @override
  State<_RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<_RoomForm> {
  String? _roomId;
  String? _proctorOne;
  String? _proctorTwo;
  bool _saving = false;

  Future<void> _save() async {
    if (_roomId == null) return;
    final room = widget.rooms.firstWhere((item) => item['id'] == _roomId);
    setState(() => _saving = true);
    try {
      await sl<ApiService>().createExamRoom(
        scheduleId: widget.scheduleId,
        roomCode: room['code'].toString(),
        capacity: room['capacity'] as int,
        proctorOneId: _proctorOne,
        proctorTwoId: _proctorTwo,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              apiErrorMessage(
                error,
                fallback: 'Không thể thêm phòng thi. Vui lòng thử lại.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Thêm phòng thi',
    children: [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Phòng'),
        items: _items(widget.rooms),
        onChanged: (value) => setState(() => _roomId = value),
      ),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Giám thị 1'),
        items: _items(widget.teachers),
        onChanged: (value) => setState(() => _proctorOne = value),
      ),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Giám thị 2 (không bắt buộc)',
        ),
        items: _items(widget.teachers),
        onChanged: (value) => setState(() => _proctorTwo = value),
      ),
      FilledButton.icon(
        onPressed: _roomId == null || _saving ? null : _save,
        icon: const Icon(Icons.check_rounded),
        label: Text(_saving ? 'Đang thêm...' : 'Thêm phòng'),
      ),
    ],
  );
}

class _GraderForm extends StatefulWidget {
  const _GraderForm({required this.teachers, required this.classes});
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> classes;

  @override
  State<_GraderForm> createState() => _GraderFormState();
}

class _GraderFormState extends State<_GraderForm> {
  String? _teacher;
  String? _classId;

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Phân công chấm',
    children: [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Lớp'),
        items: _items(widget.classes),
        onChanged: (value) => setState(() => _classId = value),
      ),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Giáo viên'),
        items: widget.teachers
            .map(
              (item) => DropdownMenuItem<String>(
                value: item['teacherId'].toString(),
                child: Text(item['teacherName'].toString()),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _teacher = value),
      ),
      FilledButton.icon(
        onPressed: _teacher == null || _classId == null
            ? null
            : () => Navigator.pop(context, {
                'teacherId': _teacher!,
                'classId': _classId!,
              }),
        icon: const Icon(Icons.check_rounded),
        label: const Text('Lưu phân công'),
      ),
    ],
  );
}

class _PeriodForm extends StatefulWidget {
  const _PeriodForm();

  @override
  State<_PeriodForm> createState() => _PeriodFormState();
}

class _PeriodFormState extends State<_PeriodForm> {
  final _api = sl<ApiService>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  late final Future<List<Object>> _options = Future.wait<Object>([
    _api.academicYears(),
    _api.semesters(),
  ]);
  String? _year;
  String? _semester;
  String? _grade;
  DateTime? _start;
  DateTime? _end;
  bool _saving = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<DateTime?> _date(DateTime? value) => showDatePicker(
    context: context,
    initialDate: value ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2040),
  );

  Future<void> _save() async {
    if (_code.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _year == null ||
        _semester == null ||
        _start == null ||
        _end == null) {
      return _message('Hãy nhập và chọn đầy đủ thông tin.');
    }
    if (_end!.isBefore(_start!)) {
      return _message('Ngày kết thúc không hợp lệ.');
    }
    setState(() => _saving = true);
    try {
      await _api.saveExamPeriod(
        code: _code.text.trim(),
        name: _name.text.trim(),
        academicYearId: _year!,
        semesterId: _semester!,
        gradeLevel: _grade,
        startDate: _start!,
        endDate: _end!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback: 'Không thể tạo kỳ thi. Vui lòng thử lại.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Object>>(
    future: _options,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final years = snapshot.data![0] as List<Map<String, dynamic>>;
      final semesters = (snapshot.data![1] as List<Map<String, dynamic>>)
          .where((item) => _year == null || item['academicYearId'] == _year)
          .toList();
      return _Sheet(
        title: 'Tạo kỳ thi',
        children: [
          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Mã kỳ thi'),
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Tên kỳ thi'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _year,
            decoration: const InputDecoration(labelText: 'Năm học'),
            items: _items(years),
            onChanged: (value) => setState(() {
              _year = value;
              _semester = null;
            }),
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(_year),
            initialValue: _semester,
            decoration: const InputDecoration(labelText: 'Học kỳ'),
            items: _items(semesters),
            onChanged: (value) => setState(() => _semester = value),
          ),
          DropdownButtonFormField<String?>(
            initialValue: _grade,
            decoration: const InputDecoration(labelText: 'Phạm vi'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Toàn trường')),
              DropdownMenuItem(value: 'K8', child: Text('Khối 8')),
              DropdownMenuItem(value: 'K9', child: Text('Khối 9')),
              DropdownMenuItem(value: 'K10', child: Text('Khối 10')),
              DropdownMenuItem(value: 'K11', child: Text('Khối 11')),
              DropdownMenuItem(value: 'K12', child: Text('Khối 12')),
            ],
            onChanged: (value) => setState(() => _grade = value),
          ),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Bắt đầu',
                  value: _start,
                  onTap: () async {
                    final value = await _date(_start);
                    if (value != null) setState(() => _start = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: 'Kết thúc',
                  value: _end,
                  onTap: () async {
                    final value = await _date(_end);
                    if (value != null) setState(() => _end = value);
                  },
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Đang tạo...' : 'Tạo kỳ thi'),
          ),
        ],
      );
    },
  );
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm({
    required this.periodId,
    required this.start,
    required this.end,
  });
  final String periodId;
  final DateTime start;
  final DateTime end;

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _api = sl<ApiService>();
  final _time = TextEditingController(text: '07:30');
  final _minutes = TextEditingController(text: '90');
  late final Future<List<Object>> _options = Future.wait<Object>([
    _api.subjects(),
    _api.classes(),
  ]);
  String? _subject;
  final _classes = <String>{};
  late DateTime _date = widget.start;
  bool _saving = false;

  @override
  void dispose() {
    _time.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final minutes = int.tryParse(_minutes.text);
    final validTime = RegExp(
      r'^(?:[01]\d|2[0-3]):[0-5]\d$',
    ).hasMatch(_time.text);
    if (_subject == null || _classes.isEmpty) {
      return _message('Hãy chọn môn và lớp.');
    }
    if (!validTime || minutes == null || minutes < 15 || minutes > 480) {
      return _message('Giờ thi hoặc thời lượng không hợp lệ.');
    }
    setState(() => _saving = true);
    try {
      await _api.saveExamSchedule(
        periodId: widget.periodId,
        subjectId: _subject!,
        classIds: _classes.toList(),
        examDate: _date,
        startTime: _time.text,
        durationMinutes: minutes,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _message(
          apiErrorMessage(
            error,
            fallback: 'Không thể tạo lịch thi. Vui lòng thử lại.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Object>>(
    future: _options,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final subjects = snapshot.data![0] as List<Map<String, dynamic>>;
      final classes = snapshot.data![1] as List<Map<String, dynamic>>;
      return _Sheet(
        title: 'Thêm lịch thi',
        children: [
          DropdownButtonFormField<String>(
            initialValue: _subject,
            decoration: const InputDecoration(labelText: 'Môn thi'),
            items: _items(subjects),
            onChanged: (value) => setState(() => _subject = value),
          ),
          Text('Lớp dự thi', style: Theme.of(context).textTheme.titleSmall),
          ...classes.map(
            (item) => CheckboxListTile(
              value: _classes.contains(item['id']),
              title: Text((item['name'] ?? item['code']).toString()),
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (checked) => setState(() {
                checked == true
                    ? _classes.add(item['id'].toString())
                    : _classes.remove(item['id']);
              }),
            ),
          ),
          _DateButton(
            label: 'Ngày thi',
            value: _date,
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: widget.start,
                lastDate: widget.end,
              );
              if (value != null) setState(() => _date = value);
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _time,
                  decoration: const InputDecoration(labelText: 'Giờ bắt đầu'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số phút'),
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Đang tạo...' : 'Tạo lịch thi'),
          ),
        ],
      );
    },
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: ListView.separated(
      itemCount: children.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => index == 0
          ? Text(title, style: Theme.of(context).textTheme.titleLarge)
          : children[index - 1],
    ),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text(value == null ? label : _format(value!)),
  );
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label);
  final Object? value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          '${value ?? 0}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(label),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});
  final Object? error;
  final Future<void> Function() retry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          apiErrorMessage(error, fallback: 'Không thể tải dữ liệu kỳ thi.'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: retry, child: const Text('Thử lại')),
      ],
    ),
  );
}

List<DropdownMenuItem<String>> _items(List<Map<String, dynamic>> values) =>
    values
        .map(
          (item) => DropdownMenuItem(
            value: item['id'].toString(),
            child: Text(
              (item['name'] ?? item['fullName'] ?? item['code']).toString(),
            ),
          ),
        )
        .toList();

String _format(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';
