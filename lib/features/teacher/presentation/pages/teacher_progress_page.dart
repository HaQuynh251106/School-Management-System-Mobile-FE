import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/role_page_intro.dart';

/// F06/F07 dành cho giáo viên: ghi nhận thực dạy hoặc báo nghỉ + ngày bù.
class TeacherProgressPage extends StatefulWidget {
  const TeacherProgressPage({super.key});

  @override
  State<TeacherProgressPage> createState() => _TeacherProgressPageState();
}

class _TeacherProgressPageState extends State<TeacherProgressPage> {
  final _api = sl<ApiService>();
  final _topic = TextEditingController();
  final _reason = TextEditingController();
  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _history = [];
  String? _slotId;
  DateTime _date = DateTime.now();
  DateTime? _makeupDate;
  String _status = 'COMPLETED';
  int _periods = 1;
  bool _loading = true;
  StreamSubscription<RealtimeEvent>? _progressEvents;

  Map<String, dynamic>? get _slot {
    for (final slot in _slots) {
      if ('${slot['id']}' == _slotId) return slot;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _progressEvents = (sl<RealtimeService>()..connect()).events
        .where((event) => event.type == 'TEACHING_PROGRESS_UPDATED')
        .listen((_) => _reloadHistory());
    _bootstrap();
  }

  @override
  void dispose() {
    _progressEvents?.cancel();
    _topic.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      _slots = await _api.myTimetable();
      _slotId ??= _slots.isEmpty ? null : '${_slots.first['id']}';
      await _reloadHistory();
    } catch (error) {
      _show('Không thể tải lịch dạy. Vui lòng thử lại.', error: true);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadHistory() async {
    final semesterId = _slot?['semesterId']?.toString();
    if (semesterId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final history = await _api.teachingProgress(semesterId: semesterId);
      if (mounted) {
        setState(() {
          _history = history;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _show('Không thể tải nhật ký giảng dạy. Vui lòng thử lại.', error: true);
    }
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: initial.subtract(const Duration(days: 180)),
    lastDate: initial.add(const Duration(days: 365)),
  );

  static const _dayCodeByWeekday = <int, String>{
    DateTime.monday: 'MON',
    DateTime.tuesday: 'TUE',
    DateTime.wednesday: 'WED',
    DateTime.thursday: 'THU',
    DateTime.friday: 'FRI',
    DateTime.saturday: 'SAT',
    DateTime.sunday: 'SUN',
  };

  bool get _dateMatchesSlot =>
      _slot?['dayOfWeek'] == _dayCodeByWeekday[_date.weekday];

  void _selectSlotDate(Map<String, dynamic> slot) {
    final target = '${slot['dayOfWeek']}';
    var date = _date;
    for (var offset = 0; offset < 7; offset++) {
      final candidate = DateTime.now().subtract(Duration(days: offset));
      if (_dayCodeByWeekday[candidate.weekday] == target) {
        date = candidate;
        break;
      }
    }
    _date = DateTime(date.year, date.month, date.day);
  }

  Future<void> _save() async {
    if (_slotId == null || _topic.text.trim().isEmpty) {
      return _show('Hãy chọn tiết và nhập nội dung bài học', error: true);
    }
    if (!_dateMatchesSlot) {
      return _show(
        'Ngày đã chọn không đúng thứ của tiết trong thời khóa biểu. Hãy chọn đúng ngày dạy thực tế.',
        error: true,
      );
    }
    if (_status == 'CANCELLED' && _reason.text.trim().length < 5) {
      return _show('Tiết hủy cần lý do ít nhất 5 ký tự', error: true);
    }
    setState(() => _loading = true);
    try {
      await _api.saveTeachingProgress({
        'timetableSlotId': _slotId,
        'lessonDate': _iso(_date),
        'completedPeriods': _status == 'COMPLETED' ? _periods : 0,
        'topic': _topic.text.trim(),
        'status': _status,
        'reason': _status == 'CANCELLED' ? _reason.text.trim() : null,
        'makeupDate': _makeupDate == null ? null : _iso(_makeupDate!),
      });
      _show(
        _status == 'COMPLETED'
            ? 'Đã cập nhật tiến độ thực dạy'
            : 'Đã gửi ngoại lệ/lịch bù cho quản trị viên',
      );
      _topic.clear();
      _reason.clear();
      _makeupDate = null;
      await _reloadHistory();
    } catch (error) {
      _show('Không thể lưu cập nhật. Vui lòng thử lại.', error: true);
      if (mounted) setState(() => _loading = false);
    }
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tiến độ giảng dạy'),
      backgroundColor: AppColors.teacherAccent,
    ),
    body: RefreshIndicator(
      onRefresh: _bootstrap,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RolePageIntro(
            title: 'Cập nhật sau từng buổi dạy',
            subtitle:
                'Ghi đúng nội dung đã hoàn thành. Nếu nghỉ, khai báo lý do và đề xuất ngày bù để nhà trường duyệt.',
            accent: AppColors.teacherAccent,
            icon: Icons.history_edu_rounded,
          ),
          if (_slots.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có tiết dạy được phân công.'),
              ),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _slotId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tiết trong TKB'),
              items: _slots
                  .map(
                    (slot) => DropdownMenuItem(
                      value: '${slot['id']}',
                      child: Text(
                        '${slot['classCode'] ?? 'Lớp học'} · '
                        '${slot['subjectName']} · ${slot['dayOfWeek']} tiết ${slot['periodNo']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _slotId = v;
                  if (_slot != null) _selectSlotDate(_slot!);
                });
                _reloadHistory();
              },
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final value = await _pickDate(_date);
                if (value != null) {
                  setState(() => _date = value);
                  if (!_dateMatchesSlot) {
                    _show(
                      'Ngày này không đúng thứ của tiết đã chọn trong thời khóa biểu.',
                      error: true,
                    );
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ngày dạy'),
                child: Text(DateFormat('dd/MM/yyyy').format(_date)),
              ),
            ),
            if (!_dateMatchesSlot)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Chọn đúng ngày xuất hiện của tiết trong thời khóa biểu.',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'COMPLETED',
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('Đã dạy'),
                ),
                ButtonSegment(
                  value: 'CANCELLED',
                  icon: Icon(Icons.event_busy_outlined),
                  label: Text('Nghỉ/ngoại lệ'),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (v) => setState(() => _status = v.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _topic,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _status == 'COMPLETED'
                    ? 'Nội dung đã dạy'
                    : 'Nội dung dự kiến của tiết bị hủy',
                hintText: 'Ví dụ: Chương 2 · Hàm số bậc hai, bài 1',
              ),
            ),
            if (_status == 'COMPLETED') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _periods,
                decoration: const InputDecoration(
                  labelText: 'Số tiết hoàn thành',
                ),
                items: [1, 2, 3, 4, 5, 6]
                    .map(
                      (v) => DropdownMenuItem(value: v, child: Text('$v tiết')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _periods = v!),
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: _reason,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Lý do nghỉ/ngoại lệ',
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final value = await _pickDate(
                    _date.add(const Duration(days: 1)),
                  );
                  if (value != null) setState(() => _makeupDate = value);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày bù đề xuất (không bắt buộc)',
                  ),
                  child: Text(
                    _makeupDate == null
                        ? 'Chạm để chọn'
                        : DateFormat('dd/MM/yyyy').format(_makeupDate!),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(
                _status == 'COMPLETED' ? 'Lưu tiến độ' : 'Gửi ngoại lệ',
              ),
            ),
          ],
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
          const Divider(height: 32),
          Text(
            'Nhật ký học kỳ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Chưa có lần cập nhật nào.'),
            ),
          ..._history.map(
            (item) => Card(
              child: ListTile(
                leading: Icon(
                  item['status'] == 'COMPLETED'
                      ? Icons.check_circle
                      : Icons.event_busy,
                  color: item['status'] == 'COMPLETED'
                      ? AppColors.success
                      : AppColors.warning,
                ),
                title: Text('${item['classCode']} · ${item['subjectName']}'),
                subtitle: Text(
                  '${item['lessonDate']} · ${item['topic']}\n'
                  '${item['status'] == 'COMPLETED' ? '${item['completedPeriods']} tiết' : 'Lịch bù: ${item['makeupDate'] ?? 'chưa đề xuất'} · ${_makeupStatus(item['makeupStatus'])}'}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _iso(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _makeupStatus(Object? value) => switch ('$value') {
  'PROPOSED' => 'Chờ duyệt',
  'APPROVED' => 'Đã duyệt đề xuất, chờ phát hành lịch',
  'REJECTED' => 'Đã từ chối',
  _ => 'Chưa gửi',
};
