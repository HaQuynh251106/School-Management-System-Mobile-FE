import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class TimetableSchedulingPage extends StatefulWidget {
  const TimetableSchedulingPage({super.key});

  @override
  State<TimetableSchedulingPage> createState() =>
      _TimetableSchedulingPageState();
}

class _Cell {
  _Cell({this.subject, this.teacher, this.room});
  String? subject;
  String? teacher;
  String? room;

  bool get isEmpty => subject == null;
}

class _TimetableSchedulingPageState extends State<TimetableSchedulingPage> {
  String _class = '10A1';
  String _semester = 'HK2';
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _periods = ['T1', 'T2', 'T3', 'T4', 'T5'];

  late Map<String, _Cell> _slots = {
    'T2-T1': _Cell(subject: 'Toán', teacher: 'Hoa', room: 'P201'),
    'T2-T2': _Cell(subject: 'Vật lý', teacher: 'Minh', room: 'P201'),
    'T2-T3': _Cell(subject: 'Ngữ văn', teacher: 'Hồng', room: 'P201'),
    'T3-T1': _Cell(subject: 'T.Anh', teacher: 'Bảo', room: 'P201'),
    'T3-T2': _Cell(subject: 'Sinh', teacher: 'Bình', room: 'Lab 1'),
    'T4-T1': _Cell(subject: 'Toán', teacher: 'Hoa', room: 'P201'),
    'T5-T2': _Cell(subject: 'Vật lý', teacher: 'Minh', room: 'Lab 1'),
    'T6-T1': _Cell(subject: 'Ngữ văn', teacher: 'Hồng', room: 'P201'),
  };

  @override
  Widget build(BuildContext context) {
    final filled = _slots.values.where((c) => !c.isEmpty).length;
    final total = _days.length * _periods.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xếp thời khóa biểu'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Auto-arrange',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang xếp tự động... (mock)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _class,
                    decoration: const InputDecoration(
                        labelText: 'Lớp', isDense: true),
                    items: ['10A1', '10A2', '8A1']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _class = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _semester,
                    decoration: const InputDecoration(
                        labelText: 'Học kỳ', isDense: true),
                    items: ['HK1', 'HK2']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _semester = v!),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.adminAccent.withOpacity(0.06),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.adminAccent),
                const SizedBox(width: 6),
                Text(
                  'Đã xếp $filled/$total tiết — không có xung đột',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 40),
                        ..._days.map((d) => _HeaderCell(text: d)),
                      ],
                    ),
                    for (final p in _periods) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 40,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.adminAccent.withOpacity(0.06),
                              border:
                                  Border.all(color: AppColors.divider),
                            ),
                            child: Center(
                              child: Text(p,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.adminAccent)),
                            ),
                          ),
                          ..._days.map((d) {
                            final key = '$d-$p';
                            final cell = _slots[key];
                            return _GridCell(
                              cell: cell,
                              onTap: () => _editCell(key, cell),
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border:
                    Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.preview_rounded, size: 16),
                      label: const Text('Preview xung đột'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu TKB và phát hành.'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.adminAccent,
                      ),
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text('Lưu & phát hành'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCell(String key, _Cell? current) async {
    String? subject = current?.subject;
    String? teacher = current?.teacher;
    String? room = current?.room;
    final result = await showModalBottomSheet<_Cell>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tiết $key',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: subject,
                decoration: const InputDecoration(
                    labelText: 'Môn', isDense: true),
                items: [
                  'Toán',
                  'Vật lý',
                  'Hóa học',
                  'Ngữ văn',
                  'T.Anh',
                  'Sinh'
                ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => subject = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: teacher,
                decoration: const InputDecoration(
                    labelText: 'Giáo viên', isDense: true),
                items: ['Hoa', 'Minh', 'Hồng', 'Bảo', 'Bình']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => teacher = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: room,
                decoration: const InputDecoration(
                    labelText: 'Phòng', isDense: true),
                items: ['P201', 'P202', 'P105', 'Lab 1', 'Gym']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => room = v),
              ),
              if (current != null && !current.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: AppColors.success),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'Không có xung đột GV/phòng/lớp ở slot này',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (current != null && !current.isEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(ctx, _Cell()),
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        label: const Text('Xóa',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                  if (current != null && !current.isEmpty)
                    const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                          ctx,
                          _Cell(
                              subject: subject,
                              teacher: teacher,
                              room: room)),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.adminAccent),
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        if (result.isEmpty) {
          _slots.remove(key);
        } else {
          _slots[key] = result;
        }
      });
    }
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.adminAccent,
        border: Border.all(color: AppColors.adminAccent),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({this.cell, required this.onTap});
  final _Cell? cell;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = cell == null || cell!.isEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 64,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isEmpty
              ? AppColors.background
              : AppColors.adminAccent.withOpacity(0.08),
          border: Border.all(color: AppColors.divider),
        ),
        child: isEmpty
            ? const Center(
                child: Icon(Icons.add_rounded,
                    size: 20, color: AppColors.textSecondary),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(cell!.subject!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.adminAccent)),
                  const SizedBox(height: 2),
                  Text(cell!.teacher ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                  Text(cell!.room ?? '',
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
      ),
    );
  }
}
