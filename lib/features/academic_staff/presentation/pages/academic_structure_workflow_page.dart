import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/role_page_intro.dart';

/// F02: năm học -> học kỳ -> lớp/môn/phòng -> GVCN -> phân lớp đầu vào.
class AcademicStructureWorkflowPage extends StatefulWidget {
  const AcademicStructureWorkflowPage({super.key});

  @override
  State<AcademicStructureWorkflowPage> createState() =>
      _AcademicStructureWorkflowPageState();
}

class _AcademicStructureWorkflowPageState
    extends State<AcademicStructureWorkflowPage> {
  final _api = sl<ApiService>();
  late Future<List<List<Map<String, dynamic>>>> _future = _load();

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        _api.academicYears(),
        _api.semesters(),
        _api.classes(),
        _api.subjects(),
        _api.rooms(),
        _api.users(role: 'TEACHER'),
      ]);

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _createYear() async {
    final code = TextEditingController();
    final name = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    final ok = await _formDialog(
      'Tạo năm học',
      [
        _field(code, 'Mã năm học', hint: '2026-2027'),
        _field(name, 'Tên hiển thị', hint: 'Năm học 2026–2027'),
        _field(start, 'Ngày bắt đầu', hint: '2026-08-01'),
        _field(end, 'Ngày kết thúc', hint: '2027-05-31'),
      ],
    );
    if (!ok) return;
    try {
      await _api.createAcademicYear({
        'code': code.text.trim(),
        'name': name.text.trim(),
        'startDate': start.text.trim(),
        'endDate': end.text.trim(),
        'status': 'PLANNED',
      });
      _message('Đã tạo năm học và 2 học kỳ mặc định');
      await _reload();
    } catch (error) {
      _message('Không thể tạo năm học. Vui lòng kiểm tra thông tin và thử lại.',
          error: true);
    }
  }

  Future<void> _createClass(List<Map<String, dynamic>> years,
      List<Map<String, dynamic>> rooms) async {
    if (years.isEmpty) return _message('Hãy tạo năm học trước', error: true);
    final code = TextEditingController();
    final name = TextEditingController();
    final grade = TextEditingController(text: '10');
    final capacity = TextEditingController(text: '45');
    String yearId = '${years.first['id']}';
    String? roomId;
    String shift = 'MORNING';
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('Tạo lớp học'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    _field(code, 'Mã lớp', hint: '10A1'),
                    _field(name, 'Tên lớp', hint: 'Lớp 10A1'),
                    _field(grade, 'Khối', hint: '10'),
                    _field(capacity, 'Sĩ số tối đa', numeric: true),
                    DropdownButtonFormField<String>(
                      initialValue: yearId,
                      decoration: const InputDecoration(labelText: 'Năm học'),
                      items: years
                          .map((e) => DropdownMenuItem(
                              value: '${e['id']}', child: Text(_name(e))))
                          .toList(),
                      onChanged: (v) => yearId = v!,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: shift,
                      decoration: const InputDecoration(labelText: 'Ca học'),
                      items: const [
                        DropdownMenuItem(
                            value: 'MORNING', child: Text('Ca sáng')),
                        DropdownMenuItem(
                            value: 'AFTERNOON', child: Text('Ca chiều')),
                      ],
                      onChanged: (v) => shift = v!,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      initialValue: roomId,
                      decoration:
                          const InputDecoration(labelText: 'Phòng chính'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('Chưa gán phòng')),
                        ...rooms.map((e) => DropdownMenuItem<String?>(
                            value: '${e['id']}', child: Text(_name(e)))),
                      ],
                      onChanged: (v) => setDialogState(() => roomId = v),
                    ),
                  ]),
                ),
              ),
              actions: _dialogActions(context),
            ),
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await _api.createClass({
        'code': code.text.trim(),
        'name': name.text.trim(),
        'gradeLevel': grade.text.trim(),
        'academicYearId': yearId,
        'studyShift': shift,
        'capacity': int.tryParse(capacity.text) ?? 45,
        'roomId': roomId,
      });
      _message('Đã tạo lớp học');
      await _reload();
    } catch (error) {
      _message('Không thể tạo lớp. Vui lòng kiểm tra thông tin và thử lại.',
          error: true);
    }
  }

  Future<void> _assignHomeroom(Map<String, dynamic> classroom,
      List<Map<String, dynamic>> teachers) async {
    if (teachers.isEmpty) {
      return _message('Chưa có giáo viên hoạt động', error: true);
    }
    String teacherId = '${teachers.first['id']}';
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Gán GVCN · ${_name(classroom)}'),
            content: DropdownButtonFormField<String>(
              initialValue: teacherId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Giáo viên'),
              items: teachers
                  .map((e) => DropdownMenuItem(
                      value: '${e['id']}', child: Text(_name(e))))
                  .toList(),
              onChanged: (v) => teacherId = v!,
            ),
            actions: _dialogActions(context),
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await _api.assignHomeroomTeacher('${classroom['id']}', teacherId);
      _message('Đã cập nhật giáo viên chủ nhiệm');
      await _reload();
    } catch (error) {
      _message('Không thể gán giáo viên chủ nhiệm. Vui lòng thử lại.',
          error: true);
    }
  }

  Future<void> _createCatalog(bool subject) async {
    final code = TextEditingController();
    final name = TextEditingController();
    final extra = TextEditingController(text: subject ? '1' : '45');
    final ok = await _formDialog(subject ? 'Thêm môn học' : 'Thêm phòng học', [
      _field(code, subject ? 'Mã môn' : 'Mã phòng'),
      _field(name, 'Tên hiển thị'),
      _field(extra, subject ? 'Hệ số' : 'Sức chứa', numeric: true),
    ]);
    if (!ok) return;
    try {
      if (subject) {
        await _api.createSubject({
          'code': code.text.trim(),
          'name': name.text.trim(),
          'coefficient': double.tryParse(extra.text) ?? 1,
        });
      } else {
        await _api.createRoom({
          'code': code.text.trim(),
          'name': name.text.trim(),
          'capacity': int.tryParse(extra.text) ?? 45,
          'supportsMorning': true,
          'supportsAfternoon': true,
        });
      }
      _message(subject ? 'Đã thêm môn học' : 'Đã thêm phòng học');
      await _reload();
    } catch (error) {
      _message('Không thể lưu thông tin. Vui lòng thử lại.', error: true);
    }
  }

  Future<bool> _formDialog(String title, List<Widget> fields) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: fields),
            ),
          ),
          actions: _dialogActions(context),
        ),
      ) ??
      false;

  List<Widget> _dialogActions(BuildContext context) => [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Lưu'),
        ),
      ];

  Widget _field(TextEditingController controller, String label,
          {String? hint, bool numeric = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : null,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : null));
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cơ cấu và phân lớp'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Năm học'),
                Tab(text: 'Lớp & GVCN'),
                Tab(text: 'Môn & Phòng'),
                Tab(text: 'Phân lớp'),
              ],
            ),
          ),
          body: FutureBuilder<List<List<Map<String, dynamic>>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(retry: _reload);
              }
              final data = snapshot.data!;
              return TabBarView(children: [
                _YearsTab(
                  years: data[0],
                  semesters: data[1],
                  classes: data[2],
                  subjects: data[3],
                  rooms: data[4],
                  onCreate: _createYear,
                  onReload: _reload,
                ),
                _ClassesTab(
                  classes: data[2],
                  years: data[0],
                  rooms: data[4],
                  teachers: data[5],
                  onCreate: () => _createClass(data[0], data[4]),
                  onAssign: _assignHomeroom,
                ),
                _CatalogTab(
                  subjects: data[3],
                  rooms: data[4],
                  onCreateSubject: () => _createCatalog(true),
                  onCreateRoom: () => _createCatalog(false),
                ),
                _PlacementTab(years: data[0], api: _api),
              ]);
            },
          ),
        ),
      );
}

class _YearsTab extends StatelessWidget {
  const _YearsTab(
      {required this.years,
      required this.semesters,
      required this.classes,
      required this.subjects,
      required this.rooms,
      required this.onCreate,
      required this.onReload});
  final List<Map<String, dynamic>> years;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> rooms;
  final Future<void> Function() onCreate;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onReload,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const RolePageIntro(
            title: 'Bước 1 · Chốt khung năm học',
            subtitle:
                'Tạo năm học trước. Hai học kỳ sẽ được tạo sẵn theo khoảng thời gian đã chọn.',
            accent: AppColors.academicStaffAccent,
            icon: Icons.date_range_rounded,
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.1,
            children: [
              _AcademicShortcut(
                value: '${classes.length}',
                label: 'Lớp & GVCN',
                icon: Icons.groups_rounded,
                onTap: () => DefaultTabController.of(context).animateTo(1),
              ),
              _AcademicShortcut(
                value: '${subjects.length}',
                label: 'Môn học',
                icon: Icons.menu_book_rounded,
                onTap: () => DefaultTabController.of(context).animateTo(2),
              ),
              _AcademicShortcut(
                value: '${rooms.length}',
                label: 'Phòng học',
                icon: Icons.meeting_room_rounded,
                onTap: () => DefaultTabController.of(context).animateTo(2),
              ),
              _AcademicShortcut(
                value: 'Tự động',
                label: 'Phân lớp đầu vào',
                icon: Icons.auto_awesome_rounded,
                onTap: () => DefaultTabController.of(context).animateTo(3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tạo năm học')),
          const SizedBox(height: 12),
          ...years.map((year) {
            final children = semesters
                .where((s) => '${s['academicYearId']}' == '${year['id']}')
                .toList();
            return Card(
              child: ExpansionTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(_name(year)),
                subtitle: Text('${year['startDate']} → ${year['endDate']}'),
                trailing:
                    Chip(label: Text(_statusLabel('${year['status'] ?? ''}'))),
                children: children
                    .map((s) => ListTile(
                          leading: const Icon(Icons.view_week_outlined),
                          title: Text(_name(s)),
                          subtitle: Text('${s['startDate']} → ${s['endDate']}'),
                        ))
                    .toList(),
              ),
            );
          }),
        ]),
      );
}

class _AcademicShortcut extends StatelessWidget {
  const _AcademicShortcut({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(icon, color: AppColors.academicStaffAccent, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
                    ]),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.academicStaffAccent, size: 16),
            ]),
          ),
        ),
      );
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab(
      {required this.classes,
      required this.years,
      required this.rooms,
      required this.teachers,
      required this.onCreate,
      required this.onAssign});
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> years;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> teachers;
  final VoidCallback onCreate;
  final Future<void> Function(Map<String, dynamic>, List<Map<String, dynamic>>)
      onAssign;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Tạo lớp học')),
          const SizedBox(height: 12),
          ...classes.map((item) => Card(
                child: ListTile(
                  leading:
                      CircleAvatar(child: Text('${item['gradeLevel'] ?? '?'}')),
                  title: Text(_name(item)),
                  subtitle: Text(
                      '${item['studentCount'] ?? 0}/${item['capacity'] ?? 45} HS · ${item['studyShift'] == 'AFTERNOON' ? 'Chiều' : 'Sáng'}\nGVCN: ${item['homeroomTeacherName'] ?? 'Chưa gán'}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Gán GVCN',
                    onPressed: () => onAssign(item, teachers),
                    icon: const Icon(Icons.badge_outlined),
                  ),
                ),
              )),
        ],
      );
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab(
      {required this.subjects,
      required this.rooms,
      required this.onCreateSubject,
      required this.onCreateRoom});
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> rooms;
  final VoidCallback onCreateSubject;
  final VoidCallback onCreateRoom;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(
                child: FilledButton.tonalIcon(
                    onPressed: onCreateSubject,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Thêm môn'))),
            const SizedBox(width: 10),
            Expanded(
                child: FilledButton.tonalIcon(
                    onPressed: onCreateRoom,
                    icon: const Icon(Icons.meeting_room_rounded),
                    label: const Text('Thêm phòng'))),
          ]),
          const SizedBox(height: 16),
          Text('Môn học (${subjects.length})',
              style: Theme.of(context).textTheme.titleMedium),
          ...subjects.map((e) => ListTile(
                leading: const Icon(Icons.book_outlined),
                title: Text(_name(e)),
                subtitle:
                    Text('${e['code'] ?? ''} · Hệ số ${e['coefficient'] ?? 1}'),
              )),
          const Divider(),
          Text('Phòng học (${rooms.length})',
              style: Theme.of(context).textTheme.titleMedium),
          ...rooms.map((e) => ListTile(
                leading: const Icon(Icons.door_sliding_outlined),
                title: Text(_name(e)),
                subtitle: Text('Sức chứa ${e['capacity'] ?? 0}'),
              )),
        ],
      );
}

class _PlacementTab extends StatefulWidget {
  const _PlacementTab({required this.years, required this.api});
  final List<Map<String, dynamic>> years;
  final ApiService api;

  @override
  State<_PlacementTab> createState() => _PlacementTabState();
}

class _PlacementTabState extends State<_PlacementTab> {
  String? _yearId;
  String _grade = '10';
  int _capacity = 45;
  int _desiredClassCount = 0;
  bool _autoCreateClasses = true;
  bool _balanceGender = true;
  String _studyShift = 'MORNING';
  final Map<String, String> _lockedPlacements = {};
  Map<String, dynamic>? _preview;
  bool _loading = false;

  Map<String, dynamic> get _payload => {
        'academicYearId': _yearId,
        'gradeLevel': _grade,
        'maxStudentsPerClass': _capacity,
        'desiredClassCount': _desiredClassCount,
        'autoCreateClasses': _autoCreateClasses,
        'balanceGender': _balanceGender,
        'defaultStudyShift': _studyShift,
        'lockedPlacements': _lockedPlacements.entries
            .map((entry) => {
                  'studentId': entry.key,
                  'classCode': entry.value,
                })
            .toList(),
      };

  Future<void> _setPlacementLock(
      String studentId, String classCode, bool locked) async {
    setState(() {
      if (locked) {
        _lockedPlacements[studentId] = classCode;
      } else {
        _lockedPlacements.remove(studentId);
      }
      _preview = null;
    });
    await _previewPlacement();
  }

  Future<void> _previewPlacement() async {
    if (_yearId == null) return;
    setState(() => _loading = true);
    try {
      final result = await widget.api.previewIntakePlacement(_payload);
      if (mounted) setState(() => _preview = result);
    } catch (error) {
      _show('Không thể lập phương án phân lớp. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    if (_preview == null) return;
    setState(() => _loading = true);
    try {
      final result = await widget.api.applyIntakePlacement(_payload);
      _show('Đã phân lớp ${result['assignedCount'] ?? 0} học sinh');
      if (mounted) setState(() => _preview = null);
    } catch (error) {
      _show('Không thể lưu kết quả phân lớp. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _yearId ??= widget.years.isEmpty ? null : '${widget.years.first['id']}';
    final plans = (_preview?['classes'] as List? ?? const []);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const RolePageIntro(
        title: 'Bước 5 · Xem phương án phân lớp',
        subtitle:
            'Hệ thống cân bằng sĩ số và giới tính. Danh sách chỉ được lưu sau khi quản trị viên xác nhận.',
        accent: AppColors.academicStaffAccent,
        icon: Icons.auto_awesome_rounded,
      ),
      DropdownButtonFormField<String>(
        initialValue: _yearId,
        decoration: const InputDecoration(labelText: 'Năm học'),
        items: widget.years
            .map((e) =>
                DropdownMenuItem(value: '${e['id']}', child: Text(_name(e))))
            .toList(),
        onChanged: (v) => setState(() {
          _yearId = v;
          _lockedPlacements.clear();
          _preview = null;
        }),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: DropdownButtonFormField<String>(
          initialValue: _grade,
          decoration: const InputDecoration(labelText: 'Khối'),
          items: ['6', '7', '8', '9', '10', '11', '12']
              .map((e) => DropdownMenuItem(value: e, child: Text('Khối $e')))
              .toList(),
          onChanged: (v) => setState(() {
            _grade = v!;
            _lockedPlacements.clear();
            _preview = null;
          }),
        )),
        const SizedBox(width: 10),
        Expanded(
            child: DropdownButtonFormField<int>(
          initialValue: _capacity,
          decoration: const InputDecoration(labelText: 'Sĩ số/lớp'),
          items: [35, 40, 45, 50]
              .map((e) => DropdownMenuItem(value: e, child: Text('$e HS')))
              .toList(),
          onChanged: (v) => setState(() {
            _capacity = v!;
            _preview = null;
          }),
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _desiredClassCount,
            decoration: const InputDecoration(
              labelText: 'Số lớp mong muốn',
              helperText: 'Tự tính nếu chọn 0',
            ),
            items: [0, 1, 2, 3, 4, 5, 6, 8, 10]
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value == 0 ? 'Tự động' : '$value lớp'),
                    ))
                .toList(),
            onChanged: (value) => setState(() {
              _desiredClassCount = value ?? 0;
              _preview = null;
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _studyShift,
            decoration: const InputDecoration(
              labelText: 'Ca cho lớp tạo mới',
            ),
            items: const [
              DropdownMenuItem(value: 'MORNING', child: Text('Ca sáng')),
              DropdownMenuItem(value: 'AFTERNOON', child: Text('Ca chiều')),
            ],
            onChanged: (value) => setState(() {
              _studyShift = value ?? 'MORNING';
              _preview = null;
            }),
          ),
        ),
      ]),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Tự tạo lớp còn thiếu'),
        subtitle: const Text(
            'Tắt nếu muốn quản trị viên tạo đủ lớp trước khi chạy thuật toán.'),
        value: _autoCreateClasses,
        onChanged: (value) => setState(() {
          _autoCreateClasses = value;
          _preview = null;
        }),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Cân bằng giới tính giữa các lớp'),
        value: _balanceGender,
        onChanged: (value) => setState(() {
          _balanceGender = value;
          _preview = null;
        }),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _loading || _yearId == null ? null : _previewPlacement,
        icon: const Icon(Icons.preview_rounded),
        label: const Text('Xem phương án'),
      ),
      if (_loading)
        const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator()),
      if (_preview != null) ...[
        const SizedBox(height: 16),
        Text('${_preview!['candidateCount'] ?? 0} ứng viên · '
            '${_preview!['assignedCount'] ?? 0} được xếp · '
            '${_preview!['newClassCount'] ?? 0} lớp mới'),
        ...((_preview!['warnings'] as List?) ?? const []).map(
          (warning) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber_rounded,
                color: AppColors.warning),
            title: Text('$warning'),
          ),
        ),
        ...plans.map((raw) {
          final item = Map<String, dynamic>.from(raw as Map);
          final classCode = '${item['classCode'] ?? ''}';
          final students = (item['students'] as List? ?? const [])
              .map((rawStudent) => Map<String, dynamic>.from(rawStudent as Map))
              .toList();
          return Card(
              child: ExpansionTile(
            leading: const Icon(Icons.groups_rounded),
            title:
                Text('$classCode${item['newClass'] == true ? ' · mới' : ''}'),
            subtitle: Text(
                '${item['assignedStudents'] ?? 0}/${item['capacity'] ?? _capacity} HS · '
                'Nam ${item['maleCount'] ?? 0} · Nữ ${item['femaleCount'] ?? 0}'),
            children: students.isEmpty
                ? const [
                    ListTile(
                      title: Text('Chưa có học sinh được xếp vào lớp này.'),
                    )
                  ]
                : students.map((student) {
                    final studentId = '${student['id']}';
                    final locked = _lockedPlacements[studentId] == classCode ||
                        student['locked'] == true;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        locked ? Icons.lock_rounded : Icons.person_outline,
                        color: locked ? AppColors.academicStaffAccent : null,
                      ),
                      title: Text('${student['fullName'] ?? 'Học sinh'}'),
                      subtitle: Text('${student['studentCode'] ?? ''}'
                          '${student['gender'] == null ? '' : ' · ${student['gender']}'}'),
                      trailing: TextButton(
                        onPressed: _loading
                            ? null
                            : () => _setPlacementLock(
                                  studentId,
                                  classCode,
                                  !locked,
                                ),
                        child: Text(locked ? 'Bỏ khóa' : 'Giữ lớp'),
                      ),
                    );
                  }).toList(),
          ));
        }),
        if (_lockedPlacements.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Đã khóa ${_lockedPlacements.length} học sinh vào lớp đã chọn. '
              'Hệ thống vẫn tự cân bằng các học sinh còn lại.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        FilledButton.icon(
          onPressed: _loading || (_preview!['unassignedCount'] ?? 0) != 0
              ? null
              : _apply,
          icon: const Icon(Icons.done_all_rounded),
          label: const Text('Xác nhận phân lớp'),
        ),
      ],
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.retry});
  final Future<void> Function() retry;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Không thể tải dữ liệu. Vui lòng thử lại.',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: retry, child: const Text('Thử lại')),
        ]),
      ));
}

String _name(Map<String, dynamic> item) =>
    '${item['name'] ?? item['fullName'] ?? item['code'] ?? 'Chưa đặt tên'}';

String _statusLabel(String value) => switch (value.toUpperCase()) {
      'ACTIVE' => 'Đang áp dụng',
      'PLANNED' => 'Sắp tới',
      'COMPLETED' => 'Đã kết thúc',
      _ => 'Chưa xác định',
    };
