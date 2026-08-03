import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../../core/widgets/glass_ui.dart';
import 'create_record_sheet.dart';
import 'module_hub_screen.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({
    super.key,
    required this.module,
    required this.accent,
  });
  final AppModule module;
  final Color accent;

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  final search = TextEditingController();
  Timer? debounce;
  late Future<List<Map<String, dynamic>>> future;
  int currentPage = 0;
  int pageSize = 20;

  @override
  void initState() {
    super.initState();
    future = load();
  }

  @override
  void dispose() {
    search.dispose();
    debounce?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> load() =>
      context.read<AppSession>().api.list(
        widget.module.endpoint,
        query: search.text.trim().isEmpty ? null : {'q': search.text.trim()},
      );

  void reload() => setState(() => future = load());

  Future<void> create() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateRecordSheet(
        kind: widget.module.createKind!,
        accent: widget.accent,
      ),
    );
    if (changed == true) reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.module.title),
      actions: [
        IconButton(onPressed: reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    floatingActionButton: widget.module.createKind == null
        ? null
        : FloatingActionButton.extended(
            onPressed: create,
            backgroundColor: widget.accent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm mới'),
          ),
    body: Column(
      children: [
        GlassPanel(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          padding: const EdgeInsets.all(7),
          child: SearchBar(
            controller: search,
            hintText: 'Tìm trong ${widget.module.title.toLowerCase()}',
            leading: const Icon(Icons.search_rounded),
            trailing: search.text.isEmpty
                ? null
                : [
                    IconButton(
                      onPressed: () {
                        search.clear();
                        reload();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
            onChanged: (_) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 450), () {
                currentPage = 0;
                reload();
              });
            },
          ),
        ),
        Expanded(
          child: AsyncStateView<List<Map<String, dynamic>>>(
            future: future,
            onRetry: reload,
            builder: (context, items) {
              final term = search.text.trim().toLowerCase();
              final filtered = term.isEmpty
                  ? items
                  : items
                        .where(
                          (item) => item.values.any(
                            (value) =>
                                value != null &&
                                '$value'.toLowerCase().contains(term),
                          ),
                        )
                        .toList();
              final pageCount = filtered.isEmpty
                  ? 1
                  : (filtered.length / pageSize).ceil();
              if (currentPage >= pageCount) currentPage = pageCount - 1;
              final start = currentPage * pageSize;
              final visible = filtered.skip(start).take(pageSize).toList();
              if (filtered.isEmpty) {
                return EmptyState(
                  title: 'Chưa có dữ liệu',
                  message: search.text.isEmpty
                      ? 'Dữ liệu sẽ xuất hiện tại đây khi được tạo.'
                      : 'Không có kết quả phù hợp với từ khóa.',
                  icon: widget.module.icon,
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () async => reload(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, index) => EntranceMotion(
                          index: index,
                          child: _DataCard(
                            data: visible[index],
                            icon: widget.module.icon,
                            accent: widget.accent,
                            endpoint: widget.module.endpoint,
                            onChanged: reload,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        widget.module.createKind != null &&
                                MediaQuery.sizeOf(context).width >= 700
                            ? 180
                            : 16,
                        14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${start + 1}–${start + visible.length} / ${filtered.length}',
                          ),
                          const Spacer(),
                          DropdownButton<int>(
                            value: pageSize,
                            underline: const SizedBox.shrink(),
                            items: const [10, 20, 50]
                                .map(
                                  (size) => DropdownMenuItem(
                                    value: size,
                                    child: Text('$size dòng'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              pageSize = value ?? 20;
                              currentPage = 0;
                            }),
                          ),
                          IconButton(
                            tooltip: 'Trang trước',
                            onPressed: currentPage == 0
                                ? null
                                : () => setState(() => currentPage--),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          Text('${currentPage + 1}/$pageCount'),
                          IconButton(
                            tooltip: 'Trang sau',
                            onPressed: currentPage + 1 >= pageCount
                                ? null
                                : () => setState(() => currentPage++),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.data,
    required this.icon,
    required this.accent,
    required this.endpoint,
    required this.onChanged,
  });
  final Map<String, dynamic> data;
  final IconData icon;
  final Color accent;
  final String endpoint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final title = _first(data, const [
      'title',
      'name',
      'fullName',
      'code',
      'subjectName',
      'className',
      'username',
    ]);
    final status = _first(data, const ['status', 'state', 'paymentStatus']);
    final details = data.entries
        .where(
          (entry) =>
              entry.value != null &&
              entry.value.toString().isNotEmpty &&
              !_isTechnicalKey(entry.key) &&
              !const ['title', 'name', 'fullName', 'code'].contains(entry.key),
        )
        .take(3)
        .map((entry) => '${_label(entry.key)}: ${_display(entry.value)}')
        .join(' · ');
    return GlassPanel(
      borderRadius: 23,
      onTap: () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => _DetailSheet(
          data: data,
          title: title,
          endpoint: endpoint,
          onChanged: onChanged,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: accent.withValues(alpha: .11),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Bản ghi #${data['id'] ?? ''}' : title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _display(status),
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.data,
    required this.title,
    required this.endpoint,
    required this.onChanged,
  });
  final Map<String, dynamic> data;
  final String title;
  final String endpoint;
  final VoidCallback onChanged;

  Future<void> _delete(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa “$title”?'),
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
    if (accepted != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final api = context.read<AppSession>().api;
    try {
      await api.delete('$endpoint/${data['id']}');
      if (!context.mounted) return;
      navigator.pop();
      onChanged();
      messenger.showSnackBar(const SnackBar(content: Text('Đã xóa dữ liệu.')));
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể xóa vì dữ liệu đang được sử dụng hoặc bạn không có quyền.',
          ),
        ),
      );
    }
  }

  Future<void> _edit(BuildContext context) async {
    final code = TextEditingController(text: '${data['code'] ?? ''}');
    final name = TextEditingController(text: '${data['name'] ?? ''}');
    final number = TextEditingController(
      text: '${data['coefficient'] ?? data['capacity'] ?? ''}',
    );
    String grade = '${data['gradeLevel'] ?? 'K10'}';
    String shift = '${data['studyShift'] ?? 'MORNING'}';
    bool morning = data['supportsMorning'] != false;
    bool afternoon = data['supportsAfternoon'] != false;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Sửa $title'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: code,
                    decoration: const InputDecoration(labelText: 'Mã'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Tên'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: number,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: endpoint == '/subjects' ? 'Hệ số' : 'Sức chứa',
                    ),
                  ),
                  if (endpoint == '/classes') ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: grade,
                      decoration: const InputDecoration(labelText: 'Khối'),
                      items: const [
                        DropdownMenuItem(value: 'K10', child: Text('Khối 10')),
                        DropdownMenuItem(value: 'K11', child: Text('Khối 11')),
                        DropdownMenuItem(value: 'K12', child: Text('Khối 12')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => grade = value!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: shift,
                      decoration: const InputDecoration(labelText: 'Ca học'),
                      items: const [
                        DropdownMenuItem(
                          value: 'MORNING',
                          child: Text('Ca sáng'),
                        ),
                        DropdownMenuItem(
                          value: 'AFTERNOON',
                          child: Text('Ca chiều'),
                        ),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => shift = value!),
                    ),
                  ],
                  if (endpoint == '/rooms') ...[
                    SwitchListTile(
                      value: morning,
                      title: const Text('Cho phép ca sáng'),
                      onChanged: (value) =>
                          setDialogState(() => morning = value),
                    ),
                    SwitchListTile(
                      value: afternoon,
                      title: const Text('Cho phép ca chiều'),
                      onChanged: (value) =>
                          setDialogState(() => afternoon = value),
                    ),
                  ],
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
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !context.mounted) return;
    final payload = switch (endpoint) {
      '/subjects' => {
        'code': code.text.trim(),
        'name': name.text.trim(),
        'coefficient': double.tryParse(number.text.trim()),
      },
      '/rooms' => {
        'code': code.text.trim(),
        'name': name.text.trim(),
        'capacity': int.tryParse(number.text.trim()),
        'supportsMorning': morning,
        'supportsAfternoon': afternoon,
      },
      _ => {
        'code': code.text.trim(),
        'name': name.text.trim(),
        'gradeLevel': grade,
        'academicYearId': data['academicYearId'],
        'studyShift': shift,
        'capacity': int.tryParse(number.text.trim()),
        'roomId': data['roomId'],
      },
    };
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final api = context.read<AppSession>().api;
    try {
      await api.put('$endpoint/${data['id']}', payload);
      if (!context.mounted) return;
      navigator.pop();
      onChanged();
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã cập nhật dữ liệu.')),
      );
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Không thể cập nhật. Hãy kiểm tra dữ liệu bắt buộc.'),
          ),
        );
      }
    } finally {
      code.dispose();
      name.dispose();
      number.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? 'Chi tiết' : title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          ...data.entries
              .where((e) => e.value != null && !_isTechnicalKey(e.key))
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 118,
                        child: Text(
                          _label(entry.key),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(child: Text(_display(entry.value))),
                    ],
                  ),
                ),
              ),
          if (context.read<AppSession>().user?.role == 'ADMIN' &&
              const {
                '/classes',
                '/subjects',
                '/rooms',
                '/announcements',
              }.contains(endpoint)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (const {
                  '/classes',
                  '/subjects',
                  '/rooms',
                }.contains(endpoint))
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _edit(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Sửa'),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

String _first(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && '$value'.isNotEmpty) return '$value';
  }
  return '';
}

String _display(dynamic value) {
  if (value is Map) {
    return _first(value.cast<String, dynamic>(), const [
      'name',
      'fullName',
      'code',
      'title',
      'id',
    ]);
  }
  if (value is List) return '${value.length} mục';
  if (value == true) return 'Có';
  if (value == false) return 'Không';
  const translations = {
    'ACTIVE': 'Đang hoạt động',
    'INACTIVE': 'Ngừng hoạt động',
    'DRAFT': 'Bản nháp',
    'OPEN': 'Đang mở',
    'CLOSED': 'Đã kết thúc',
    'PLANNED': 'Đã lên kế hoạch',
    'CONFIRMED': 'Đã xác nhận',
    'TEACHER': 'Giáo viên',
    'STUDENT': 'Học sinh',
    'PARENT': 'Phụ huynh',
    'ADMIN': 'Quản trị viên',
    'MORNING': 'Ca sáng',
    'AFTERNOON': 'Ca chiều',
  };
  if (value is String && translations.containsKey(value)) {
    return translations[value]!;
  }
  return '$value';
}

String _label(String key) {
  const labels = {
    'status': 'Trạng thái',
    'username': 'Tài khoản',
    'role': 'Vai trò',
    'className': 'Lớp',
    'subjectName': 'Môn học',
    'teacherName': 'Giáo viên',
    'date': 'Ngày',
    'deadline': 'Hạn nộp',
    'amount': 'Số tiền',
    'email': 'Email',
    'phone': 'Điện thoại',
    'classCode': 'Lớp',
    'studyShift': 'Ca học',
    'gradeLevel': 'Khối',
    'studentCount': 'Sĩ số',
    'coefficient': 'Hệ số',
    'capacity': 'Sức chứa',
    'roomCode': 'Phòng',
    'startDate': 'Ngày bắt đầu',
    'endDate': 'Ngày kết thúc',
    'createdAt': 'Ngày tạo',
  };
  return labels[key] ??
      key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)!.toLowerCase()}',
      );
}

bool _isTechnicalKey(String key) {
  final normalized = key.toLowerCase();
  return normalized == 'id' ||
      normalized.endsWith('id') ||
      normalized.endsWith('at') ||
      normalized == 'createdby' ||
      normalized == 'updatedby' ||
      normalized == 'version';
}
