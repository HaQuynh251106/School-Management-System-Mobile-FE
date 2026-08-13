import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class ExamCategoriesPage extends StatefulWidget {
  const ExamCategoriesPage({super.key});

  @override
  State<ExamCategoriesPage> createState() => _ExamCategoriesPageState();
}

class _ExamCategoriesPageState extends State<ExamCategoriesPage> {
  late Future<List<Map<String, dynamic>>> future = _load();

  Future<List<Map<String, dynamic>>> _load() =>
      sl<ApiService>().examCategories();
  void _reload() => setState(() => future = _load());

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final code = TextEditingController(text: '${item?['code'] ?? ''}');
    final name = TextEditingController(text: '${item?['name'] ?? ''}');
    final weight = TextEditingController(text: '${item?['weight'] ?? 1}');
    final count = TextEditingController(text: '${item?['requiredCount'] ?? 1}');
    final key = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(item == null ? 'Thêm loại điểm' : 'Sửa loại điểm'),
            content: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: code,
                  decoration: const InputDecoration(labelText: 'Mã loại điểm'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Không được để trống'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Không được để trống'
                      : null,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: weight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Hệ số'),
                      validator: (value) {
                        final number = double.tryParse(value ?? '');
                        return number == null || number <= 0 || number > 10
                            ? '0–10'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: count,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Số đầu điểm'),
                      validator: (value) {
                        final number = int.tryParse(value ?? '');
                        return number == null || number < 1 || number > 10
                            ? '1–10'
                            : null;
                      },
                    ),
                  ),
                ]),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy')),
              FilledButton(
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Lưu')),
            ],
          ),
        ) ??
        false;
    if (accepted) {
      try {
        final data = {
          'code': code.text.trim(),
          'name': name.text.trim(),
          'weight': double.parse(weight.text),
          'requiredCount': int.parse(count.text),
        };
        if (item == null) {
          await sl<ApiService>().createExamCategory(data);
        } else {
          await sl<ApiService>().updateExamCategory('${item['id']}', data);
        }
        _reload();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không thể lưu loại điểm. Hãy kiểm tra mã bị trùng.'),
            backgroundColor: AppColors.error,
          ));
        }
      }
    }
    code.dispose();
    name.dispose();
    weight.dispose();
    count.dispose();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xóa loại điểm?'),
            content: Text('${item['name']} sẽ bị xóa nếu chưa được sử dụng.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy')),
              FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Xóa')),
            ],
          ),
        ) ??
        false;
    if (!accepted) return;
    try {
      await sl<ApiService>().deleteExamCategory('${item['id']}');
      _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể xóa loại điểm đang được sử dụng.'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cấu hình loại điểm'),
          backgroundColor: AppColors.adminAccent,
          actions: [
            IconButton(
                onPressed: () => _edit(), icon: const Icon(Icons.add_rounded)),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tải lại'),
                ),
              );
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return const Center(child: Text('Chưa có loại điểm'));
            }
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      onTap: () => _edit(item),
                      leading: CircleAvatar(child: Text('${item['code']}')),
                      title: Text('${item['name']}'),
                      subtitle: Text(
                          'Hệ số ${item['weight']} · ${item['requiredCount'] ?? 1} đầu điểm'),
                      trailing: IconButton(
                        onPressed: () => _delete(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
}
