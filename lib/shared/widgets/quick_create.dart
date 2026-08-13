import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';

class QuickCreateButton extends StatelessWidget {
  const QuickCreateButton({
    super.key,
    required this.role,
    required this.accent,
    this.onCreated,
    this.userOnly = false,
  });

  final String role;
  final Color accent;
  final VoidCallback? onCreated;
  final bool userOnly;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        heroTag: 'quick-create-$role',
        backgroundColor: accent,
        foregroundColor: Colors.white,
        onPressed: () => _openMenu(context),
        icon:
            Icon(userOnly ? Icons.person_add_alt_1_rounded : Icons.add_rounded),
        label: Text(userOnly ? 'Thêm tài khoản' : 'Thêm mới'),
      );

  Future<void> _openMenu(BuildContext context) async {
    if (userOnly) {
      await _openCreateSheet(
        context,
        const _CreateOption(
          'USER',
          'Người dùng',
          'Học sinh, giáo viên, phụ huynh',
          Icons.person_add_alt_1_rounded,
          'Con người',
        ),
      );
      return;
    }

    final options = role == 'ADMIN'
        ? const [
            _CreateOption(
                'USER',
                'Người dùng',
                'Học sinh, giáo viên, phụ huynh',
                Icons.person_add_alt_1_rounded,
                'Con người'),
            _CreateOption('CLASS', 'Lớp học', 'Khối, ca học và phòng mặc định',
                Icons.groups_2_rounded, 'Cơ cấu đào tạo'),
            _CreateOption('SUBJECT', 'Môn học', 'Mã môn và hệ số',
                Icons.menu_book_rounded, 'Cơ cấu đào tạo'),
            _CreateOption('ROOM', 'Phòng học', 'Sức chứa và ca sử dụng',
                Icons.meeting_room_rounded, 'Cơ cấu đào tạo'),
            _CreateOption('FEE', 'Đợt thu', 'Hạn nộp và khối áp dụng',
                Icons.receipt_long_rounded, 'Vận hành'),
            _CreateOption('ANNOUNCEMENT', 'Thông báo',
                'Gửi theo đúng đối tượng', Icons.campaign_rounded, 'Vận hành'),
          ]
        : const [
            _CreateOption('ASSIGNMENT', 'Bài tập', 'Giao bài và phát hành ngay',
                Icons.assignment_add, 'Giảng dạy'),
            _CreateOption(
                'ANNOUNCEMENT',
                'Thông báo lớp',
                'Gửi học sinh và phụ huynh',
                Icons.campaign_rounded,
                'Trao đổi'),
          ];

    final selected = await showModalBottomSheet<_CreateOption>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn muốn thêm gì?',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              'Các tác vụ được sắp xếp theo nhóm để thao tác nhanh hơn.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i == 0 || options[i - 1].group != options[i].group)
                      Padding(
                        padding:
                            EdgeInsets.only(top: i == 0 ? 0 : 14, bottom: 6),
                        child: Text(options[i].group.toUpperCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .6,
                            )),
                      ),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(options[i].icon, color: accent),
                        ),
                        title: Text(options[i].title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(options[i].subtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pop(sheetContext, options[i]),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await _openCreateSheet(context, selected);
  }

  Future<void> _openCreateSheet(
    BuildContext context,
    _CreateOption selected,
  ) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateEntitySheet(
        option: selected,
        role: role,
        accent: accent,
      ),
    );
    if (created == true) onCreated?.call();
  }
}

class _CreateOption {
  const _CreateOption(
      this.type, this.title, this.subtitle, this.icon, this.group);
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String group;
}

class _CreateEntitySheet extends StatefulWidget {
  const _CreateEntitySheet({
    required this.option,
    required this.role,
    required this.accent,
  });
  final _CreateOption option;
  final String role;
  final Color accent;

  @override
  State<_CreateEntitySheet> createState() => _CreateEntitySheetState();
}

class _CreateEntitySheetState extends State<_CreateEntitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _years = [];
  bool _loading = true;
  bool _saving = false;
  String _role = 'STUDENT';
  String? _classId;
  String? _subjectId;
  String? _yearId;
  String _shift = 'MORNING';
  String _audience = 'ALL';
  String _category = 'GENERAL';
  String _priority = 'NORMAL';
  bool _publishNow = true;
  bool _allowLate = false;
  bool _morning = true;
  bool _afternoon = true;
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  TextEditingController field(String name) =>
      _fields.putIfAbsent(name, TextEditingController.new);

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final api = sl<ApiService>();
    try {
      if (widget.option.type == 'USER' ||
          widget.option.type == 'CLASS' ||
          widget.option.type == 'ASSIGNMENT' ||
          widget.option.type == 'ANNOUNCEMENT') {
        _classes = widget.role == 'TEACHER'
            ? await api.teachingClasses()
            : await api.classes();
      }
      if (widget.option.type == 'USER' || widget.option.type == 'ASSIGNMENT') {
        _subjects = await api.subjects();
      }
      if (widget.option.type == 'CLASS' || widget.option.type == 'FEE') {
        _years = await api.academicYears();
      }
      if (_classes.isNotEmpty) _classId = _idOf(_classes.first);
      if (_subjects.isNotEmpty) _subjectId = _idOf(_subjects.first);
      if (_years.isNotEmpty) _yearId = _idOf(_years.first);
      if (widget.role == 'TEACHER' && _classId != null) {
        _audience = 'CLASS_ALL:$_classId';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm ${widget.option.title.toLowerCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  _FormHero(option: widget.option, accent: widget.accent),
                  const SizedBox(height: 22),
                  ..._buildFields(),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Đang lưu...' : 'Tạo mới'),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() => switch (widget.option.type) {
        'USER' => _userFields(),
        'CLASS' => _classFields(),
        'SUBJECT' => _subjectFields(),
        'ROOM' => _roomFields(),
        'FEE' => _feeFields(),
        'ASSIGNMENT' => _assignmentFields(),
        _ => _announcementFields(),
      };

  List<Widget> _userFields() => [
        _input('name', 'Họ và tên', Icons.badge_outlined),
        _gap,
        _input('username', 'Tên đăng nhập', Icons.alternate_email_rounded),
        _gap,
        _input('password', 'Mật khẩu ban đầu', Icons.password_rounded,
            obscure: true, minLength: 10),
        _gap,
        _select(
          label: 'Vai trò',
          value: _role,
          items: const {
            'STUDENT': 'Học sinh',
            'TEACHER': 'Giáo viên',
            'PARENT': 'Phụ huynh',
            'ADMIN': 'Quản trị viên',
          },
          onChanged: (value) => setState(() => _role = value),
        ),
        _gap,
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.badge_outlined, color: widget.accent),
          title: const Text('Mã người dùng được cấp tự động'),
          subtitle: const Text(
            'Hệ thống tạo mã duy nhất theo vai trò sau khi lưu tài khoản.',
          ),
        ),
        if (_role == 'STUDENT') ...[
          _objectSelect(
              label: 'Lớp học',
              value: _classId,
              rows: _classes,
              onChanged: (value) => setState(() => _classId = value)),
        ],
        if (_role == 'TEACHER') ...[
          _objectSelect(
            label: 'Môn chuyên ngành',
            value: _subjectId,
            rows: _subjects,
            onChanged: (value) => setState(() => _subjectId = value),
          ),
        ],
        _gap,
        _input(
          'email',
          'Email',
          Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          pattern: RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'),
          invalidMessage: 'Email không hợp lệ',
        ),
        _gap,
        _input(
          'phone',
          'Số điện thoại',
          Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          pattern: RegExp(r'^[0-9+ .()\-]{7,30}$'),
          invalidMessage: 'Số điện thoại không hợp lệ',
        ),
      ];

  List<Widget> _classFields() => [
        _input('code', 'Mã lớp, ví dụ 10A1', Icons.tag_rounded),
        _gap,
        _input('name', 'Tên lớp', Icons.groups_2_outlined),
        _gap,
        _input('grade', 'Khối, ví dụ 10', Icons.school_outlined),
        _gap,
        _objectSelect(
            label: 'Năm học',
            value: _yearId,
            rows: _years,
            onChanged: (value) => setState(() => _yearId = value)),
        _gap,
        _select(
          label: 'Ca học',
          value: _shift,
          items: const {'MORNING': 'Ca sáng', 'AFTERNOON': 'Ca chiều'},
          onChanged: (value) => setState(() => _shift = value),
        ),
        _gap,
        _input('capacity', 'Sĩ số tối đa', Icons.people_alt_outlined,
            keyboardType: TextInputType.number),
      ];

  List<Widget> _subjectFields() => [
        _input('code', 'Mã môn học', Icons.tag_rounded),
        _gap,
        _input('name', 'Tên môn học', Icons.menu_book_rounded),
        _gap,
        _input('coefficient', 'Hệ số', Icons.calculate_outlined,
            keyboardType: TextInputType.number),
      ];

  List<Widget> _roomFields() => [
        _input('code', 'Mã phòng', Icons.tag_rounded),
        _gap,
        _input('name', 'Tên phòng học', Icons.meeting_room_outlined),
        _gap,
        _input('capacity', 'Sức chứa', Icons.people_alt_outlined,
            keyboardType: TextInputType.number),
        _gap,
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cho phép sử dụng ca sáng'),
          value: _morning,
          onChanged: (value) => setState(() => _morning = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cho phép sử dụng ca chiều'),
          value: _afternoon,
          onChanged: (value) => setState(() => _afternoon = value),
        ),
      ];

  List<Widget> _feeFields() => [
        _input('code', 'Mã đợt thu', Icons.tag_rounded),
        _gap,
        _input('name', 'Tên đợt thu', Icons.receipt_long_outlined),
        _gap,
        _objectSelect(
            label: 'Năm học',
            value: _yearId,
            rows: _years,
            onChanged: (value) => setState(() => _yearId = value)),
        _gap,
        _input('grades', 'Khối áp dụng, ví dụ 10,11,12',
            Icons.filter_alt_outlined),
        _gap,
        _dateTile('Hạn nộp'),
      ];

  List<Widget> _assignmentFields() => [
        _objectSelect(
            label: 'Lớp nhận bài',
            value: _classId,
            rows: _classes,
            onChanged: (value) => setState(() => _classId = value)),
        _gap,
        _objectSelect(
            label: 'Môn học',
            value: _subjectId,
            rows: _subjects,
            onChanged: (value) => setState(() => _subjectId = value)),
        _gap,
        _input('title', 'Tên bài tập', Icons.title_rounded),
        _gap,
        _input('description', 'Yêu cầu bài tập', Icons.notes_rounded,
            maxLines: 4),
        _gap,
        _dateTile('Hạn nộp'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cho phép nộp muộn'),
          value: _allowLate,
          onChanged: (value) => setState(() => _allowLate = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Phát hành ngay'),
          subtitle: const Text('Học sinh sẽ nhận thông báo sau khi tạo'),
          value: _publishNow,
          onChanged: (value) => setState(() => _publishNow = value),
        ),
      ];

  List<Widget> _announcementFields() => [
        if (widget.role == 'TEACHER') ...[
          _objectSelect(
              label: 'Lớp nhận thông báo',
              value: _classId,
              rows: _classes,
              onChanged: (value) {
                setState(() {
                  _classId = value;
                  _audience = 'CLASS_ALL:$value';
                });
              }),
          _gap,
          _select(
            label: 'Người nhận',
            value: _audience.startsWith('CLASS_')
                ? _audience.split(':').first
                : 'CLASS_ALL',
            items: const {
              'CLASS_ALL': 'Học sinh và phụ huynh',
              'CLASS_STUDENTS': 'Chỉ học sinh',
              'CLASS_PARENTS': 'Chỉ phụ huynh',
            },
            onChanged: (value) =>
                setState(() => _audience = '$value:$_classId'),
          ),
        ] else
          _select(
            label: 'Đối tượng nhận',
            value: _audience,
            items: const {
              'ALL': 'Toàn trường',
              'TEACHER': 'Toàn thể giáo viên',
              'STUDENT': 'Toàn thể học sinh',
              'PARENT': 'Toàn thể phụ huynh',
            },
            onChanged: (value) => setState(() => _audience = value),
          ),
        _gap,
        _input('title', 'Tiêu đề thông báo', Icons.title_rounded),
        _gap,
        _input('body', 'Nội dung', Icons.notes_rounded, maxLines: 5),
        _gap,
        _select(
          label: 'Loại thông báo',
          value: _category,
          items: widget.role == 'TEACHER'
              ? const {
                  'STUDENT_STATUS': 'Tình hình học sinh',
                  'ATTENDANCE': 'Điểm danh',
                  'GRADE': 'Điểm số',
                  'PARENT_MEETING': 'Họp phụ huynh',
                }
              : const {
                  'GENERAL': 'Thông báo chung',
                  'HOLIDAY': 'Nghỉ lễ',
                  'EVENT': 'Sự kiện',
                  'PARENT_MEETING': 'Họp phụ huynh',
                },
          onChanged: (value) => setState(() => _category = value),
        ),
        _gap,
        _select(
          label: 'Mức độ',
          value: _priority,
          items: const {
            'NORMAL': 'Thông thường',
            'IMPORTANT': 'Quan trọng',
            'URGENT': 'Khẩn cấp',
          },
          onChanged: (value) => setState(() => _priority = value),
        ),
      ];

  Widget _input(
    String key,
    String label,
    IconData icon, {
    bool required = true,
    bool obscure = false,
    int minLength = 0,
    int maxLines = 1,
    TextInputType? keyboardType,
    RegExp? pattern,
    String? invalidMessage,
  }) =>
      TextFormField(
        controller: field(key),
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (minLength > 0 && (value?.length ?? 0) < minLength) {
            return 'Cần ít nhất $minLength ký tự';
          }
          if (value != null &&
              value.trim().isNotEmpty &&
              pattern != null &&
              !pattern.hasMatch(value.trim())) {
            return invalidMessage ?? '$label không hợp lệ';
          }
          return null;
        },
      );

  Widget _select({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        initialValue: items.containsKey(value) ? value : items.keys.first,
        decoration: InputDecoration(labelText: label),
        items: items.entries
            .map((item) =>
                DropdownMenuItem(value: item.key, child: Text(item.value)))
            .toList(),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      );

  Widget _objectSelect({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> rows,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        initialValue: rows.any((row) => _idOf(row) == value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: rows
            .map((row) => DropdownMenuItem(
                  value: _idOf(row),
                  child: Text(_labelOf(row), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        validator: (value) => value == null ? 'Vui lòng chọn $label' : null,
        onChanged: onChanged,
      );

  Widget _dateTile(String label) => Card(
        child: ListTile(
          leading: Icon(Icons.event_rounded, color: widget.accent),
          title: Text(label),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) setState(() => _date = picked);
          },
        ),
      );

  Widget get _gap => const SizedBox(height: 14);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final api = sl<ApiService>();
    try {
      switch (widget.option.type) {
        case 'USER':
          await api.createUser({
            'username': text('username'),
            'password': text('password'),
            'fullName': text('name'),
            'role': _role,
            'email': text('email'),
            'phone': text('phone'),
            'classId': _role == 'STUDENT' ? _classId : null,
            'className':
                _role == 'STUDENT' ? _labelForId(_classes, _classId) : null,
            'mainSubjectId': _role == 'TEACHER' ? _subjectId : null,
          });
        case 'CLASS':
          await api.createClass({
            'code': text('code'),
            'name': text('name'),
            'gradeLevel': text('grade'),
            'academicYearId': _yearId,
            'studyShift': _shift,
            'capacity': int.tryParse(text('capacity')) ?? 40,
          });
        case 'SUBJECT':
          await api.createSubject({
            'code': text('code'),
            'name': text('name'),
            'coefficient': double.tryParse(text('coefficient')) ?? 1,
          });
        case 'ROOM':
          await api.createRoom({
            'code': text('code'),
            'name': text('name'),
            'capacity': int.tryParse(text('capacity')) ?? 40,
            'supportsMorning': _morning,
            'supportsAfternoon': _afternoon,
          });
        case 'FEE':
          await api.createFeePeriod({
            'code': text('code'),
            'name': text('name'),
            'academicYearId': _yearId,
            'applyToGrades': text('grades'),
            'dueDate': DateFormat('yyyy-MM-dd').format(_date),
          });
        case 'ASSIGNMENT':
          await api.createAssignment({
            'classId': _classId,
            'subjectId': _subjectId,
            'title': text('title'),
            'description': text('description'),
            'deadline': _date
                .add(const Duration(hours: 23, minutes: 59))
                .toUtc()
                .toIso8601String(),
            'allowLate': _allowLate,
            'publishNow': _publishNow,
          });
        default:
          await api.createAnnouncement({
            'title': text('title'),
            'body': text('body'),
            'audience': _audience,
            'category': _category,
            'priority': _priority,
          });
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo ${widget.option.title.toLowerCase()}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String text(String key) => field(key).text.trim();
  String? nullable(String key) => text(key).isEmpty ? null : text(key);

  String _idOf(Map<String, dynamic> row) =>
      '${row['id'] ?? row['classId'] ?? row['subjectId'] ?? ''}';

  String _labelOf(Map<String, dynamic> row) =>
      '${row['code'] ?? row['classCode'] ?? row['name'] ?? row['className'] ?? row['subjectName'] ?? _idOf(row)}';

  String? _labelForId(List<Map<String, dynamic>> rows, String? id) {
    for (final row in rows) {
      if (_idOf(row) == id) return _labelOf(row);
    }
    return null;
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero({required this.option, required this.accent});
  final _CreateOption option;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: .18)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(option.icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(option.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
}
