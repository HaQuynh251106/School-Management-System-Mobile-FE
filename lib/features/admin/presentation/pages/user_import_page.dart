import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/role_page_intro.dart';

/// F03: chọn tệp -> preview từng dòng -> xác nhận commit bằng token một lần.
class UserImportPage extends StatefulWidget {
  const UserImportPage({super.key});

  @override
  State<UserImportPage> createState() => _UserImportPageState();
}

class _UserImportPageState extends State<UserImportPage> {
  PlatformFile? _file;
  Map<String, dynamic>? _preview;
  bool _loading = false;
  String _strategy = 'ALL_OR_NOTHING';

  Future<void> _downloadTemplate() async {
    setState(() => _loading = true);
    try {
      final bytes = await sl<ApiService>().userImportTemplate();
      await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu tệp mẫu nhập học sinh',
        fileName: 'mau-nhap-hoc-sinh.xlsx',
        bytes: bytes,
      );
      _message('Đã tạo tệp mẫu Excel');
    } catch (error) {
      _message('Không thể tải tệp mẫu. Vui lòng thử lại.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndPreview() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final selected = result.files.single;
    setState(() {
      _file = selected;
      _preview = null;
      _loading = true;
    });
    try {
      final preview = await sl<ApiService>().previewUserImport(
        selected.bytes!,
        selected.name,
      );
      if (!mounted) return;
      setState(() {
        _preview = preview;
        if ((preview['invalidRows'] as num? ?? 0) > 0) {
          _strategy = 'ALL_OR_NOTHING';
        }
      });
    } catch (error) {
      _message(
        'Không thể đọc tệp. Hãy kiểm tra đúng mẫu Excel và thử lại.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _commit() async {
    final file = _file;
    final preview = _preview;
    if (file?.bytes == null || preview == null) return;
    final token = preview['token']?.toString();
    if (token == null || token.isEmpty) {
      _message('Bản kiểm tra đã hết hạn. Hãy chọn lại tệp.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await sl<ApiService>().commitUserImport(
        file!.bytes!,
        file.name,
        token,
        strategy: _strategy,
      );
      if (!mounted) return;
      final imported = result['imported'] ?? result['importedRows'] ?? 0;
      final failed = result['failed'] ?? result['failedRows'] ?? 0;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đã nhập danh sách'),
          content: Text('Đã tạo $imported tài khoản/học sinh. Lỗi: $failed.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      setState(() {
        _file = null;
        _preview = null;
      });
    } catch (error) {
      _message('Không thể lưu danh sách. Vui lòng thử lại.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text, {bool error = false}) {
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
  Widget build(BuildContext context) {
    final preview = _preview;
    final rows = (preview?['rows'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final invalid = (preview?['invalidRows'] as num? ?? 0).toInt();
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập học sinh từ Excel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RolePageIntro(
            title: 'Nhập danh sách người dùng',
            subtitle:
                'Kiểm tra từng dòng và sửa lỗi trước khi lưu vào hệ thống.',
            accent: AppColors.adminAccent,
            icon: Icons.upload_file_rounded,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _downloadTemplate,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Tải tệp mẫu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : _pickAndPreview,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('Chọn Excel'),
                ),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_file != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_rounded),
                title: Text(_file!.name),
                subtitle: Text('${(_file!.size / 1024).toStringAsFixed(1)} KB'),
              ),
            ),
          ],
          if (preview != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('Tổng ${preview['totalRows'] ?? rows.length}'),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 17),
                  label: Text('Hợp lệ ${preview['validRows'] ?? 0}'),
                ),
                Chip(
                  avatar: const Icon(Icons.error, size: 17),
                  label: Text('Lỗi $invalid'),
                ),
              ],
            ),
            if (invalid > 0) ...[
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'ALL_OR_NOTHING',
                    label: Text('Không nhập nếu còn lỗi'),
                  ),
                  ButtonSegment(
                    value: 'SKIP_ERRORS',
                    label: Text('Bỏ dòng lỗi'),
                  ),
                ],
                selected: {_strategy},
                onSelectionChanged: (value) =>
                    setState(() => _strategy = value.first),
              ),
            ],
            const SizedBox(height: 12),
            ...rows.map((row) {
              final valid = row['valid'] == true;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (valid ? AppColors.success : AppColors.error)
                            .withValues(alpha: .12),
                    child: Text('${row['row'] ?? '?'}'),
                  ),
                  title: Text('${row['fullName'] ?? row['username'] ?? ''}'),
                  subtitle: Text(
                    valid
                        ? '${_importRoleLabel(row['role'])} · ${row['classCode'] ?? 'chưa có lớp'}'
                        : '${row['error'] ?? 'Dòng chưa hợp lệ'}',
                  ),
                  trailing: Icon(
                    valid ? Icons.check_circle : Icons.error,
                    color: valid ? AppColors.success : AppColors.error,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed:
                  _loading || (invalid > 0 && _strategy == 'ALL_OR_NOTHING')
                  ? null
                  : _commit,
              icon: const Icon(Icons.cloud_done_rounded),
              label: const Text('Xác nhận ghi dữ liệu'),
            ),
          ],
        ],
      ),
    );
  }
}

String _importRoleLabel(Object? value) => switch ('$value'.toUpperCase()) {
  'ADMIN' => 'Quản trị viên',
  'TEACHER' => 'Giáo viên',
  'STUDENT' => 'Học sinh',
  'PARENT' => 'Phụ huynh',
  _ => 'Chưa chọn vai trò',
};
