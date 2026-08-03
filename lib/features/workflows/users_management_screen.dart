import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../modules/create_record_sheet.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final search = TextEditingController();
  Timer? debounce;
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> users = [];
  String role = 'ALL';
  String? classId;
  String status = 'ALL';
  int page = 0;
  int totalPages = 1;
  int totalElements = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    search.dispose();
    debounce?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    classes = await context.read<AppSession>().api.list('/classes');
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    try {
      final result = await context.read<AppSession>().api.page(
        '/users/page',
        page: page,
        size: 20,
        query: {
          if (role != 'ALL') 'role': role,
          if (classId != null) 'classId': classId,
          if (status != 'ALL') 'status': status,
          if (search.text.trim().isNotEmpty) 'q': search.text.trim(),
          'sort': 'fullName',
        },
      );
      final rawItems = result['items'] ?? result['content'] ?? const [];
      if (!mounted) return;
      setState(() {
        users = (rawItems as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        totalPages = (result['totalPages'] as num? ?? 1).toInt().clamp(
          1,
          999999,
        );
        totalElements = (result['totalElements'] as num? ?? users.length)
            .toInt();
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _create() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateRecordSheet(kind: 'user', accent: widget.accent),
    );
    if (changed == true) _reload();
  }

  Future<void> _toggle(Map<String, dynamic> user) async {
    final locked = '${user['status']}' == 'LOCKED';
    try {
      await context.read<AppSession>().api.post(
        '/users/${user['id']}/${locked ? 'unlock' : 'lock'}',
        const {},
      );
      if (mounted) {
        _message(locked ? 'Đã mở khóa tài khoản.' : 'Đã khóa tài khoản.');
        await _reload();
      }
    } catch (error) {
      if (mounted) _message('$error');
    }
  }

  Future<void> _edit(Map<String, dynamic> user) async {
    final fullName = TextEditingController(text: '${user['fullName'] ?? ''}');
    final email = TextEditingController(text: '${user['email'] ?? ''}');
    final phone = TextEditingController(text: '${user['phone'] ?? ''}');
    final code = TextEditingController(
      text: '${user['teacherCode'] ?? user['studentCode'] ?? ''}',
    );
    String? selectedClass = user['classId']?.toString();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sửa hồ sơ người dùng'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phone,
                    decoration: const InputDecoration(labelText: 'Điện thoại'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: code,
                    decoration: InputDecoration(
                      labelText: '${user['role']}' == 'TEACHER'
                          ? 'Mã giáo viên'
                          : 'Mã học sinh',
                    ),
                  ),
                  if ('${user['role']}' == 'STUDENT') ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedClass,
                      decoration: const InputDecoration(labelText: 'Lớp'),
                      items: classes
                          .map(
                            (item) => DropdownMenuItem(
                              value: '${item['id']}',
                              child: Text('${item['name'] ?? item['code']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedClass = value),
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
    if (accepted != true || !mounted) return;
    try {
      await context.read<AppSession>().api.put('/users/${user['id']}', {
        'fullName': fullName.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        if ('${user['role']}' == 'TEACHER') 'teacherCode': code.text.trim(),
        if ('${user['role']}' == 'STUDENT') 'studentCode': code.text.trim(),
        if ('${user['role']}' == 'STUDENT') 'classId': selectedClass,
      });
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      fullName.dispose();
      email.dispose();
      phone.dispose();
      code.dispose();
    }
  }

  Future<void> _resetPassword(Map<String, dynamic> user) async {
    final password = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại mật khẩu'),
        content: TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu mới',
            helperText: 'Để trống để hệ thống tự sinh mật khẩu an toàn.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    try {
      final result = await context.read<AppSession>().api.post(
        '/users/${user['id']}/reset-password',
        password.text.trim().isEmpty
            ? const {}
            : {'newPassword': password.text.trim()},
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mật khẩu đã được đặt lại'),
          content: SelectableText('${result['password'] ?? 'Đã cập nhật'}'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      password.dispose();
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _role(String value) => switch (value) {
    'ADMIN' => 'Quản trị viên',
    'TEACHER' => 'Giáo viên',
    'PARENT' => 'Phụ huynh',
    _ => 'Học sinh',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Người dùng và phân quyền'),
      actions: [
        IconButton(
          tooltip: 'Thêm người dùng',
          onPressed: _create,
          icon: const Icon(Icons.person_add_alt_1_rounded),
        ),
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              SearchBar(
                controller: search,
                hintText: 'Tìm theo tên, tài khoản, email hoặc số điện thoại',
                leading: const Icon(Icons.search_rounded),
                onChanged: (_) {
                  debounce?.cancel();
                  debounce = Timer(const Duration(milliseconds: 400), () {
                    page = 0;
                    _reload();
                  });
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: const [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text('Tất cả vai trò'),
                        ),
                        DropdownMenuItem(
                          value: 'STUDENT',
                          child: Text('Học sinh'),
                        ),
                        DropdownMenuItem(
                          value: 'TEACHER',
                          child: Text('Giáo viên'),
                        ),
                        DropdownMenuItem(
                          value: 'PARENT',
                          child: Text('Phụ huynh'),
                        ),
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('Quản trị viên'),
                        ),
                      ],
                      onChanged: (value) {
                        role = value ?? 'ALL';
                        if (role == 'TEACHER' || role == 'ADMIN') {
                          classId = null;
                        }
                        page = 0;
                        _reload();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: const InputDecoration(labelText: 'Lớp'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả lớp'),
                        ),
                        ...classes.map(
                          (item) => DropdownMenuItem(
                            value: '${item['id']}',
                            child: Text('${item['name'] ?? item['code']}'),
                          ),
                        ),
                      ],
                      onChanged: role == 'TEACHER' || role == 'ADMIN'
                          ? null
                          : (value) {
                              classId = value;
                              page = 0;
                              _reload();
                            },
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text('Tất cả trạng thái'),
                        ),
                        DropdownMenuItem(
                          value: 'ACTIVE',
                          child: Text('Đang hoạt động'),
                        ),
                        DropdownMenuItem(
                          value: 'LOCKED',
                          child: Text('Đã khóa'),
                        ),
                      ],
                      onChanged: (value) {
                        status = value ?? 'ALL';
                        page = 0;
                        _reload();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text('Không có người dùng phù hợp.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final locked = '${user['status']}' == 'LOCKED';
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: widget.accent.withValues(alpha: .1),
                          child: Text(
                            '${user['fullName'] ?? '?'}'
                                .trim()
                                .characters
                                .first
                                .toUpperCase(),
                            style: TextStyle(color: widget.accent),
                          ),
                        ),
                        title: Text('${user['fullName'] ?? user['username']}'),
                        subtitle: Text(
                          '${user['username']} · ${_role('${user['role']}')}'
                          '${user['className'] == null ? '' : ' · ${user['className']}'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _edit(user);
                            if (value == 'toggle') _toggle(user);
                            if (value == 'reset') _resetPassword(user);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa hồ sơ'),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(
                                locked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'reset',
                              child: Text('Đặt lại mật khẩu'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Text('$totalElements tài khoản'),
                const Spacer(),
                IconButton(
                  onPressed: page == 0
                      ? null
                      : () {
                          page--;
                          _reload();
                        },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text('${page + 1}/$totalPages'),
                IconButton(
                  onPressed: page + 1 >= totalPages
                      ? null
                      : () {
                          page++;
                          _reload();
                        },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
