import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class CreateRecordSheet extends StatefulWidget {
  const CreateRecordSheet({
    super.key,
    required this.kind,
    required this.accent,
  });
  final String kind;
  final Color accent;

  @override
  State<CreateRecordSheet> createState() => _CreateRecordSheetState();
}

class _CreateRecordSheetState extends State<CreateRecordSheet> {
  final formKey = GlobalKey<FormState>();
  final values = <String, String>{};
  bool loading = false;
  String? error;

  _CreateSpec get spec => _CreateSpec.forKind(widget.kind);

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    final api = context.read<AppSession>().api;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final body = <String, dynamic>{};
      for (final field in spec.fields) {
        final value = values[field.key]?.trim() ?? '';
        if (value.isEmpty) continue;
        body[field.key] = switch (field.type) {
          _FieldType.number => num.parse(value),
          _FieldType.toggle => value == 'true',
          _ => value,
        };
      }
      if (widget.kind == 'fee') {
        final amount = body.remove('amount');
        final itemName = body.remove('feeItemName');
        final period = await api.post(spec.endpoint, body);
        if (amount != null && itemName != null) {
          await api.post('/fee-periods/${period['id']}/items', {
            'name': itemName,
            'amount': amount,
          });
        }
      } else {
        await api.post(spec.endpoint, body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (exception) {
      setState(() {
        loading = false;
        error = _friendly(exception);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 8,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(spec.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 5),
            Text(spec.subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 22),
            ...spec.fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _FormField(
                  field: field,
                  onSaved: (value) => values[field.key] = value,
                ),
              ),
            ),
            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: loading ? null : submit,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                ),
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(loading ? 'Đang lưu...' : 'Tạo mới'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _friendly(Object error) {
    final text = '$error';
    if (text.contains('400')) {
      return 'Thông tin chưa hợp lệ hoặc còn thiếu. Vui lòng kiểm tra lại.';
    }
    if (text.contains('409')) {
      return 'Dữ liệu này đã tồn tại trong hệ thống.';
    }
    if (text.contains('403')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }
    return 'Không thể lưu dữ liệu. Vui lòng thử lại.';
  }
}

class _FormField extends StatefulWidget {
  const _FormField({required this.field, required this.onSaved});
  final _FieldSpec field;
  final ValueChanged<String> onSaved;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  String? selected;
  bool enabled = false;
  Future<List<Map<String, dynamic>>>? optionsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.field.type == _FieldType.remoteSelect && optionsFuture == null) {
      optionsFuture = context.read<AppSession>().api.list(
        widget.field.endpoint!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    if (field.type == _FieldType.select) {
      return DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: InputDecoration(
          labelText: field.label,
          prefixIcon: Icon(field.icon),
        ),
        items: field.options
            .map(
              (option) =>
                  DropdownMenuItem(value: option.$1, child: Text(option.$2)),
            )
            .toList(),
        onChanged: (value) => setState(() => selected = value),
        onSaved: (value) => widget.onSaved(value ?? ''),
        validator: field.required && selected == null
            ? (_) => 'Vui lòng chọn ${field.label.toLowerCase()}'
            : null,
      );
    }
    if (field.type == _FieldType.remoteSelect) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: optionsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          return DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: InputDecoration(
              labelText: field.label,
              prefixIcon: Icon(field.icon),
              suffixIcon: snapshot.connectionState != ConnectionState.done
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(
                      '${item['name'] ?? item['fullName'] ?? item['code'] ?? item['id']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => selected = value),
            onSaved: (value) => widget.onSaved(value ?? ''),
            validator: (value) =>
                field.required && (value == null || value.isEmpty)
                ? 'Vui lòng chọn ${field.label.toLowerCase()}'
                : null,
          );
        },
      );
    }
    if (field.type == _FieldType.toggle) {
      return FormField<bool>(
        initialValue: enabled,
        onSaved: (value) => widget.onSaved('${value ?? false}'),
        builder: (state) => SwitchListTile.adaptive(
          value: state.value ?? false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
          title: Text(field.label),
          secondary: Icon(field.icon),
          onChanged: (value) {
            state.didChange(value);
            setState(() => enabled = value);
          },
          subtitle: Text((state.value ?? false) ? 'Đã bật' : 'Chưa bật'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
    return TextFormField(
      obscureText: field.type == _FieldType.password,
      keyboardType: field.type == _FieldType.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : field.type == _FieldType.date
          ? TextInputType.datetime
          : TextInputType.text,
      maxLines: field.type == _FieldType.multiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hint,
        prefixIcon: Icon(field.icon),
      ),
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return 'Vui lòng nhập ${field.label.toLowerCase()}';
        }
        if (field.type == _FieldType.password &&
            value != null &&
            value.length < 10) {
          return 'Mật khẩu cần ít nhất 10 ký tự';
        }
        return null;
      },
      onSaved: (value) => widget.onSaved(value ?? ''),
    );
  }
}

enum _FieldType {
  text,
  password,
  number,
  multiline,
  date,
  select,
  remoteSelect,
  toggle,
}

class _FieldSpec {
  const _FieldSpec(
    this.key,
    this.label,
    this.icon, {
    this.type = _FieldType.text,
    this.required = true,
    this.hint,
    this.options = const [],
    this.endpoint,
  });
  final String key;
  final String label;
  final IconData icon;
  final _FieldType type;
  final bool required;
  final String? hint;
  final List<(String, String)> options;
  final String? endpoint;
}

class _CreateSpec {
  const _CreateSpec(this.title, this.subtitle, this.endpoint, this.fields);
  final String title;
  final String subtitle;
  final String endpoint;
  final List<_FieldSpec> fields;

  static _CreateSpec forKind(String kind) => switch (kind) {
    'academicYear' => const _CreateSpec(
      'Tạo năm học',
      'Khai báo thời gian và trạng thái ban đầu của năm học',
      '/academicYears',
      [
        _FieldSpec('code', 'Mã năm học', Icons.tag, hint: '2026-2027'),
        _FieldSpec('name', 'Tên năm học', Icons.calendar_month_outlined),
        _FieldSpec(
          'startDate',
          'Ngày bắt đầu',
          Icons.event_outlined,
          type: _FieldType.date,
          hint: '2026-08-01',
        ),
        _FieldSpec(
          'endDate',
          'Ngày kết thúc',
          Icons.event_available_outlined,
          type: _FieldType.date,
          hint: '2027-05-31',
        ),
        _FieldSpec(
          'status',
          'Trạng thái',
          Icons.flag_outlined,
          type: _FieldType.select,
          options: [
            ('PLANNED', 'Đã lên kế hoạch'),
            ('ACTIVE', 'Đang hoạt động'),
          ],
        ),
      ],
    ),
    'examPeriod' => const _CreateSpec(
      'Tạo kỳ thi',
      'Tạo kỳ thi trước khi xếp lịch và công bố',
      '/exam-periods',
      [
        _FieldSpec('code', 'Mã kỳ thi', Icons.tag),
        _FieldSpec('name', 'Tên kỳ thi', Icons.fact_check_outlined),
        _FieldSpec(
          'academicYearId',
          'Năm học',
          Icons.calendar_month_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/academicYears',
        ),
        _FieldSpec(
          'semesterId',
          'Học kỳ',
          Icons.date_range_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/semesters',
        ),
        _FieldSpec(
          'gradeLevel',
          'Khối',
          Icons.stairs_outlined,
          type: _FieldType.select,
          options: [('K10', 'Khối 10'), ('K11', 'Khối 11'), ('K12', 'Khối 12')],
        ),
        _FieldSpec(
          'startDate',
          'Ngày bắt đầu',
          Icons.event_outlined,
          type: _FieldType.date,
          hint: '2026-10-15',
        ),
        _FieldSpec(
          'endDate',
          'Ngày kết thúc',
          Icons.event_available_outlined,
          type: _FieldType.date,
          hint: '2026-10-17',
        ),
      ],
    ),
    'user' => const _CreateSpec(
      'Thêm người dùng',
      'Tạo tài khoản thật trên hệ thống',
      '/users',
      [
        _FieldSpec('username', 'Tên đăng nhập', Icons.alternate_email),
        _FieldSpec(
          'password',
          'Mật khẩu',
          Icons.lock_outline,
          type: _FieldType.password,
        ),
        _FieldSpec('fullName', 'Họ và tên', Icons.badge_outlined),
        _FieldSpec(
          'role',
          'Vai trò',
          Icons.admin_panel_settings_outlined,
          type: _FieldType.select,
          options: [
            ('STUDENT', 'Học sinh'),
            ('TEACHER', 'Giáo viên'),
            ('PARENT', 'Phụ huynh'),
            ('ADMIN', 'Quản trị viên'),
          ],
        ),
        _FieldSpec('email', 'Email', Icons.email_outlined, required: false),
        _FieldSpec(
          'phone',
          'Điện thoại',
          Icons.phone_outlined,
          required: false,
        ),
        _FieldSpec(
          'classId',
          'Lớp',
          Icons.groups_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/classes',
          required: false,
        ),
      ],
    ),
    'class' => const _CreateSpec(
      'Tạo lớp học',
      'Khai báo lớp và ca học chính',
      '/classes',
      [
        _FieldSpec('code', 'Mã lớp', Icons.tag),
        _FieldSpec('name', 'Tên lớp', Icons.groups_outlined),
        _FieldSpec(
          'gradeLevel',
          'Khối',
          Icons.stairs_outlined,
          type: _FieldType.select,
          options: [('K10', 'Khối 10'), ('K11', 'Khối 11'), ('K12', 'Khối 12')],
        ),
        _FieldSpec(
          'academicYearId',
          'Năm học',
          Icons.calendar_month_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/academicYears',
        ),
        _FieldSpec(
          'studyShift',
          'Ca học',
          Icons.schedule_outlined,
          type: _FieldType.select,
          options: [('MORNING', 'Ca sáng'), ('AFTERNOON', 'Ca chiều')],
        ),
        _FieldSpec(
          'capacity',
          'Sĩ số tối đa',
          Icons.people_outline,
          type: _FieldType.number,
        ),
        _FieldSpec(
          'homeroomTeacherId',
          'Giáo viên chủ nhiệm',
          Icons.person_pin_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/users?role=TEACHER',
          required: false,
        ),
        _FieldSpec(
          'roomId',
          'Phòng học chính',
          Icons.meeting_room_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/rooms',
          required: false,
        ),
      ],
    ),
    'subject' => const _CreateSpec(
      'Thêm môn học',
      'Môn học mới sẽ dùng được trong phân công và thời khóa biểu',
      '/subjects',
      [
        _FieldSpec('code', 'Mã môn', Icons.tag),
        _FieldSpec('name', 'Tên môn học', Icons.menu_book_outlined),
        _FieldSpec(
          'coefficient',
          'Hệ số',
          Icons.calculate_outlined,
          type: _FieldType.number,
        ),
      ],
    ),
    'room' => const _CreateSpec(
      'Thêm phòng học',
      'Quản lý sức chứa và ca có thể sử dụng',
      '/rooms',
      [
        _FieldSpec('code', 'Mã phòng', Icons.tag),
        _FieldSpec('name', 'Tên phòng', Icons.meeting_room_outlined),
        _FieldSpec(
          'capacity',
          'Sức chứa',
          Icons.people_outline,
          type: _FieldType.number,
        ),
        _FieldSpec(
          'supportsMorning',
          'Cho phép ca sáng',
          Icons.wb_sunny_outlined,
          type: _FieldType.toggle,
          required: false,
        ),
        _FieldSpec(
          'supportsAfternoon',
          'Cho phép ca chiều',
          Icons.nights_stay_outlined,
          type: _FieldType.toggle,
          required: false,
        ),
      ],
    ),
    'fee' => const _CreateSpec(
      'Tạo đợt thu',
      'Đợt thu được lưu ở trạng thái nháp trước khi phát hành',
      '/fee-periods',
      [
        _FieldSpec('code', 'Mã đợt thu', Icons.tag),
        _FieldSpec('name', 'Tên khoản thu', Icons.payments_outlined),
        _FieldSpec(
          'academicYearId',
          'Năm học',
          Icons.calendar_month_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/academicYears',
        ),
        _FieldSpec(
          'applyToGrades',
          'Áp dụng cho khối',
          Icons.stairs_outlined,
          type: _FieldType.select,
          options: [
            ('K10', 'Khối 10'),
            ('K11', 'Khối 11'),
            ('K12', 'Khối 12'),
            ('K10,K11,K12', 'Toàn trường'),
          ],
        ),
        _FieldSpec('feeItemName', 'Tên khoản thu', Icons.receipt_long_outlined),
        _FieldSpec(
          'amount',
          'Số tiền',
          Icons.monetization_on_outlined,
          type: _FieldType.number,
        ),
        _FieldSpec(
          'dueDate',
          'Hạn thanh toán',
          Icons.event_available_outlined,
          type: _FieldType.date,
          hint: '2026-09-30',
        ),
      ],
    ),
    'assignment' => const _CreateSpec(
      'Giao bài tập',
      'Tạo bài và phát hành cho lớp đang dạy',
      '/assignments',
      [
        _FieldSpec('title', 'Tiêu đề', Icons.title),
        _FieldSpec(
          'description',
          'Nội dung',
          Icons.notes_outlined,
          type: _FieldType.multiline,
        ),
        _FieldSpec(
          'classId',
          'Lớp',
          Icons.groups_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/me/teaching-classes',
        ),
        _FieldSpec(
          'subjectId',
          'Môn học',
          Icons.menu_book_outlined,
          type: _FieldType.remoteSelect,
          endpoint: '/subjects',
        ),
        _FieldSpec(
          'deadline',
          'Hạn nộp',
          Icons.event_outlined,
          type: _FieldType.date,
          hint: '2026-08-10T23:59:00',
        ),
        _FieldSpec(
          'allowLate',
          'Cho phép nộp muộn',
          Icons.more_time_outlined,
          type: _FieldType.toggle,
          required: false,
        ),
        _FieldSpec(
          'publishNow',
          'Phát hành ngay',
          Icons.send_outlined,
          type: _FieldType.toggle,
          required: false,
        ),
      ],
    ),
    'leave' => const _CreateSpec(
      'Tạo đơn xin nghỉ',
      'Đơn sẽ đi qua quy trình xác nhận và GVCN duyệt',
      '/leave-requests',
      [
        _FieldSpec(
          'startDate',
          'Ngày bắt đầu',
          Icons.event_busy_outlined,
          type: _FieldType.date,
          hint: '2026-08-01',
        ),
        _FieldSpec(
          'endDate',
          'Ngày kết thúc',
          Icons.event_outlined,
          type: _FieldType.date,
          hint: '2026-08-01',
        ),
        _FieldSpec(
          'reason',
          'Lý do',
          Icons.notes_outlined,
          type: _FieldType.multiline,
        ),
      ],
    ),
    _ => const _CreateSpec(
      'Tạo thông báo',
      'Gửi thông tin đến đúng nhóm người nhận',
      '/announcements',
      [
        _FieldSpec('title', 'Tiêu đề', Icons.title),
        _FieldSpec(
          'body',
          'Nội dung',
          Icons.notes_outlined,
          type: _FieldType.multiline,
        ),
        _FieldSpec(
          'audience',
          'Người nhận',
          Icons.people_alt_outlined,
          type: _FieldType.select,
          options: [
            ('ALL', 'Toàn trường'),
            ('TEACHER', 'Giáo viên'),
            ('STUDENT', 'Học sinh'),
            ('PARENT', 'Phụ huynh'),
          ],
        ),
        _FieldSpec(
          'category',
          'Loại thông báo',
          Icons.category_outlined,
          type: _FieldType.select,
          options: [
            ('GENERAL', 'Thông báo chung'),
            ('EVENT', 'Sự kiện'),
            ('PARENT_MEETING', 'Họp phụ huynh'),
            ('GRADE', 'Điểm số'),
            ('ATTENDANCE', 'Điểm danh'),
            ('STUDENT_STATUS', 'Tình hình học sinh'),
          ],
        ),
        _FieldSpec(
          'priority',
          'Mức ưu tiên',
          Icons.priority_high_rounded,
          type: _FieldType.select,
          options: [
            ('NORMAL', 'Bình thường'),
            ('IMPORTANT', 'Quan trọng'),
            ('URGENT', 'Khẩn cấp'),
          ],
        ),
      ],
    ),
  };
}
