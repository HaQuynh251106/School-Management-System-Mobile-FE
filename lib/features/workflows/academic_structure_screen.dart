import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../modules/create_record_sheet.dart';

class AcademicStructureScreen extends StatefulWidget {
  const AcademicStructureScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<AcademicStructureScreen> createState() =>
      _AcademicStructureScreenState();
}

class _AcademicStructureScreenState extends State<AcademicStructureScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  List<Map<String, dynamic>> years = [];
  List<Map<String, dynamic>> semesters = [];
  String? yearId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 3, vsync: this);
    _reload();
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    final api = context.read<AppSession>().api;
    try {
      final loadedYears = await api.list('/academicYears');
      yearId ??= loadedYears.isEmpty ? null : '${loadedYears.first['id']}';
      final loadedSemesters = yearId == null
          ? <Map<String, dynamic>>[]
          : await api.list(
              '/semesters',
              query: {'academicYearId': yearId},
            );
      if (!mounted) return;
      setState(() {
        years = loadedYears;
        semesters = loadedSemesters;
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _createYear() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          CreateRecordSheet(kind: 'academicYear', accent: widget.accent),
    );
    if (changed == true) _reload();
  }

  Future<void> _createSemester() async {
    if (yearId == null) return;
    final code = TextEditingController();
    final name = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    int sequence = semesters.length + 1;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo học kỳ'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: code,
                  decoration: const InputDecoration(
                    labelText: 'Mã học kỳ',
                    hintText: 'HK1',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: name,
                  decoration:
                      const InputDecoration(labelText: 'Tên học kỳ'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: sequence.clamp(1, 4),
                  decoration: const InputDecoration(labelText: 'Thứ tự'),
                  items: List.generate(
                    4,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Học kỳ ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) => sequence = value ?? 1,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: start,
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    hintText: '2026-08-01',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: end,
                  decoration: const InputDecoration(
                    labelText: 'Ngày kết thúc',
                    hintText: '2026-12-31',
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
            child: const Text('Tạo học kỳ'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    try {
      await context.read<AppSession>().api.post('/semesters', {
        'academicYearId': yearId,
        'code': code.text.trim(),
        'name': name.text.trim(),
        'sequence': sequence,
        'startDate': start.text.trim(),
        'endDate': end.text.trim(),
        'status': 'PLANNED',
      });
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    } finally {
      code.dispose();
      name.dispose();
      start.dispose();
      end.dispose();
    }
  }

  Future<void> _status(
    String type,
    Map<String, dynamic> item,
    String status,
  ) async {
    try {
      await context
          .read<AppSession>()
          .api
          .put('/$type/${item['id']}/status', {'status': status});
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _delete(String type, Map<String, dynamic> item) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Chỉ dữ liệu chưa được sử dụng mới có thể xóa an toàn.',
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
    if (accepted != true || !mounted) return;
    try {
      await context.read<AppSession>().api.delete('/$type/${item['id']}');
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<List<Map<String, dynamic>>> _promotionPreview() async {
    if (yearId == null) return [];
    return context
        .read<AppSession>()
        .api
        .list('/academic-years/$yearId/promotion-preview');
  }

  String _friendly(Object error) {
    final value = '$error';
    if (value.contains('409')) {
      return 'Không thể đổi trạng thái vì còn dữ liệu hoặc quy trình chưa hoàn tất.';
    }
    if (value.contains('400')) {
      return 'Thời gian hoặc thông tin năm học/học kỳ chưa hợp lệ.';
    }
    return 'Không thể xử lý dữ liệu đào tạo.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _statusChip(String status) => Chip(
    label: Text(
      switch (status) {
        'ACTIVE' => 'Đang hoạt động',
        'CLOSED' => 'Đã kết thúc',
        _ => 'Đã lên kế hoạch',
      },
    ),
  );

  String _conduct(dynamic value) => switch ('$value') {
    'GOOD' => 'Tốt',
    'FAIR' => 'Khá',
    'AVERAGE' => 'Đạt',
    'WEAK' => 'Chưa đạt',
    _ => 'Chưa đánh giá',
  };

  String _promotion(dynamic value) => switch ('$value') {
    'PROMOTED' => 'Được lên lớp',
    'RETAKE' => 'Thi lại',
    'REPEAT' => 'Ở lại lớp',
    'INCOMPLETE' => 'Chưa đủ dữ liệu',
    _ => 'Chờ xét',
  };

  Widget _yearList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
    itemCount: years.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final item = years[index];
      final status = '${item['status'] ?? 'PLANNED'}';
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.calendar_month_outlined,
                  color: widget.accent,
                ),
                title: Text('${item['name'] ?? item['code']}'),
                subtitle:
                    Text('${item['startDate']} – ${item['endDate']}'),
                trailing: _statusChip(status),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (status == 'PLANNED')
                    FilledButton.tonal(
                      onPressed: () =>
                          _status('academicYears', item, 'ACTIVE'),
                      child: const Text('Kích hoạt'),
                    ),
                  if (status == 'ACTIVE')
                    OutlinedButton(
                      onPressed: () =>
                          _status('academicYears', item, 'CLOSED'),
                      child: const Text('Kết thúc năm học'),
                    ),
                  if (status == 'PLANNED')
                    IconButton(
                      onPressed: () => _delete('academicYears', item),
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _semesterList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
    itemCount: semesters.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final item = semesters[index];
      final status = '${item['status'] ?? 'PLANNED'}';
      return Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('${item['sequence']}')),
          title: Text('${item['name'] ?? item['code']}'),
          subtitle: Text('${item['startDate']} – ${item['endDate']}'),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _statusChip(status),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'active') {
                    _status('semesters', item, 'ACTIVE');
                  }
                  if (value == 'closed') {
                    _status('semesters', item, 'CLOSED');
                  }
                  if (value == 'delete') _delete('semesters', item);
                },
                itemBuilder: (_) => [
                  if (status == 'PLANNED')
                    const PopupMenuItem(
                      value: 'active',
                      child: Text('Kích hoạt'),
                    ),
                  if (status == 'ACTIVE')
                    const PopupMenuItem(
                      value: 'closed',
                      child: Text('Kết thúc học kỳ'),
                    ),
                  if (status == 'PLANNED')
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa học kỳ'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _summary() => FutureBuilder<List<Map<String, dynamic>>>(
    future: _promotionPreview(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Chưa thể xét lên lớp: cần đủ điểm học kỳ I, học kỳ II và hạnh kiểm.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      final items = snapshot.data ?? [];
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              title: Text('${item['studentName'] ?? item['studentId']}'),
              subtitle: Text(
                'TB năm: ${item['yearAverage'] ?? '—'} · Hạnh kiểm: ${_conduct(item['conductGrade'])}',
              ),
              trailing: Chip(
                label: Text(_promotion(item['promotionStatus'])),
              ),
            ),
          );
        },
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Năm học và tổng kết'),
      bottom: TabBar(
        controller: tabs,
        tabs: const [
          Tab(text: 'Năm học'),
          Tab(text: 'Học kỳ'),
          Tab(text: 'Tổng kết năm'),
        ],
      ),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    floatingActionButton: AnimatedBuilder(
      animation: tabs,
      builder: (context, _) => tabs.index > 1
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: tabs.index == 0 ? _createYear : _createSemester,
              backgroundColor: widget.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                tabs.index == 0 ? 'Tạo năm học' : 'Tạo học kỳ',
              ),
            ),
    ),
    body: Column(
      children: [
        if (years.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DropdownButtonFormField<String>(
              initialValue: yearId,
              decoration: const InputDecoration(
                labelText: 'Năm học đang xem',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              items: years
                  .map(
                    (item) => DropdownMenuItem(
                      value: '${item['id']}',
                      child: Text('${item['name'] ?? item['code']}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                yearId = value;
                _reload();
              },
            ),
          ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: tabs,
                  children: [_yearList(), _semesterList(), _summary()],
                ),
        ),
      ],
    ),
  );
}
