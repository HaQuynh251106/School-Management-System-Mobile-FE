import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  final search = TextEditingController();
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> students = [];
  String? selectedId;
  bool loading = true;
  bool loadingStudents = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final rows = await context.read<AppSession>().api.list(
        '/me/teaching-classes',
      );
      if (!mounted) return;
      setState(() {
        classes = rows;
        selectedId = rows.isEmpty ? null : '${rows.first['id']}';
        loading = false;
      });
      await _loadStudents();
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _loadStudents() async {
    if (selectedId == null) return;
    setState(() => loadingStudents = true);
    try {
      final rows = await context.read<AppSession>().api.list(
        '/classes/$selectedId/students',
      );
      if (!mounted) return;
      setState(() {
        students = rows;
        loadingStudents = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loadingStudents = false);
        _message('$error');
      }
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  List<Map<String, dynamic>> get filteredStudents {
    final term = search.text.trim().toLowerCase();
    if (term.isEmpty) return students;
    return students.where((item) {
      return '${item['fullName'] ?? ''} ${item['studentCode'] ?? ''}'
          .toLowerCase()
          .contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = context.watch<AppSession>().user?.id;
    final selected = classes
        .where((item) => '${item['id']}' == selectedId)
        .firstOrNull;
    final homeroom = selected?['homeroomTeacherId'] == teacherId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp đang dạy'),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ dữ liệu',
            onPressed: _load,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator.adaptive(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  _ClassHero(
                    accent: widget.accent,
                    classCount: classes.length,
                    studentCount: students.length,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _IconBox(
                        icon: Icons.grid_view_rounded,
                        color: widget.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danh sách lớp phụ trách',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Chọn một lớp để xem danh sách học sinh',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (classes.isEmpty)
                    const _EmptyClass()
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: classes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final item = classes[index];
                          final active = '${item['id']}' == selectedId;
                          final isHomeroom =
                              item['homeroomTeacherId'] == teacherId;
                          return _ClassChipCard(
                            item: item,
                            selected: active,
                            isHomeroom: isHomeroom,
                            accent: widget.accent,
                            onTap: () async {
                              setState(() => selectedId = '${item['id']}');
                              await _loadStudents();
                            },
                          );
                        },
                      ),
                    ),
                  if (selected != null) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: widget.accent.withValues(alpha: .055),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 22,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _ClassFact(
                              icon: Icons.school_rounded,
                              label: 'Lớp',
                              value: '${selected['code'] ?? selected['name']}',
                              color: widget.accent,
                            ),
                            _ClassFact(
                              icon: Icons.layers_rounded,
                              label: 'Khối',
                              value: _grade(selected['gradeLevel']),
                              color: const Color(0xFF7A5AF8),
                            ),
                            _ClassFact(
                              icon: selected['studyShift'] == 'AFTERNOON'
                                  ? Icons.wb_twilight_rounded
                                  : Icons.wb_sunny_rounded,
                              label: 'Ca học',
                              value: selected['studyShift'] == 'AFTERNOON'
                                  ? 'Ca chiều'
                                  : 'Ca sáng',
                              color: const Color(0xFFF29A38),
                            ),
                            _ClassFact(
                              icon: Icons.groups_rounded,
                              label: 'Sĩ số',
                              value: '${students.length} học sinh',
                              color: const Color(0xFF079783),
                            ),
                            if (homeroom)
                              const Chip(
                                avatar: Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF079783),
                                ),
                                label: Text('Lớp chủ nhiệm'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm học sinh theo tên hoặc mã',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: search.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  search.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _IconBox(
                          icon: Icons.groups_2_rounded,
                          color: widget.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Học sinh (${filteredStudents.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (!homeroom)
                          Text(
                            'Thông tin cơ bản',
                            style: TextStyle(
                              color: widget.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (loadingStudents)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (filteredStudents.isEmpty)
                      const _EmptyStudents()
                    else
                      ...filteredStudents.indexed.map(
                        (entry) => _StudentCard(
                          index: entry.$1,
                          student: entry.$2,
                          accent: widget.accent,
                          canViewProfile: homeroom,
                          classId: selectedId!,
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  String _grade(dynamic value) => switch ('$value') {
    'K10' => 'Khối 10',
    'K11' => 'Khối 11',
    'K12' => 'Khối 12',
    _ => '$value',
  };
}

class _ClassHero extends StatelessWidget {
  const _ClassHero({
    required this.accent,
    required this.classCount,
    required this.studentCount,
  });
  final Color accent;
  final int classCount;
  final int studentCount;

  @override
  Widget build(BuildContext context) => Container(
    height: 210,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [const Color(0xFF102C57), accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: .92,
              child: Image.asset(
                'assets/illustrations/school-community-hero.png',
                width: constraints.maxWidth * .56,
                height: 210,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF102C57),
                  const Color(0xFF102C57).withValues(alpha: .92),
                  const Color(0xFF102C57).withValues(alpha: .12),
                ],
                stops: const [0, .42, .82],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'KHÔNG GIAN GIẢNG DẠY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hiểu lớp học,\nđồng hành đúng lúc',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.13,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  children: [
                    _HeroPill(
                      icon: Icons.school_rounded,
                      text: '$classCount lớp',
                    ),
                    _HeroPill(
                      icon: Icons.groups_rounded,
                      text: '$studentCount học sinh',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _ClassChipCard extends StatelessWidget {
  const _ClassChipCard({
    required this.item,
    required this.selected,
    required this.isHomeroom,
    required this.accent,
    required this.onTap,
  });
  final Map<String, dynamic> item;
  final bool selected;
  final bool isHomeroom;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 235,
    child: Card(
      color: selected ? accent.withValues(alpha: .09) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? accent : Theme.of(context).dividerColor,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Icon(Icons.school_rounded, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lớp ${item['code'] ?? item['name']}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['studyShift'] == 'AFTERNOON'
                          ? 'Ca chiều'
                          : 'Ca sáng',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (isHomeroom)
                      Text(
                        'Chủ nhiệm',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ClassFact extends StatelessWidget {
  const _ClassFact({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _IconBox(icon: icon, color: color),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    ],
  );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.index,
    required this.student,
    required this.accent,
    required this.canViewProfile,
    required this.classId,
  });
  final int index;
  final Map<String, dynamic> student;
  final Color accent;
  final bool canViewProfile;
  final String classId;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      leading: CircleAvatar(
        backgroundColor: accent.withValues(alpha: .11),
        child: Text(
          '${index + 1}',
          style: TextStyle(color: accent, fontWeight: FontWeight.w800),
        ),
      ),
      title: Text('${student['fullName'] ?? 'Học sinh'}'),
      subtitle: Text(
        '${student['studentCode'] ?? 'Chưa có mã'} · ${student['className'] ?? ''}',
      ),
      trailing: canViewProfile
          ? Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent)
          : const Icon(Icons.lock_outline_rounded, size: 18),
      onTap: canViewProfile
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => _StudentProfileSheet(
                classId: classId,
                student: student,
                accent: accent,
              ),
            )
          : null,
    ),
  );
}

class _StudentProfileSheet extends StatefulWidget {
  const _StudentProfileSheet({
    required this.classId,
    required this.student,
    required this.accent,
  });
  final String classId;
  final Map<String, dynamic> student;
  final Color accent;

  @override
  State<_StudentProfileSheet> createState() => _StudentProfileSheetState();
}

class _StudentProfileSheetState extends State<_StudentProfileSheet> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = context.read<AppSession>().api.map(
      '/classes/${widget.classId}/students/${widget.student['id']}/profile',
    );
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .9,
    child: FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final rows = [
          ('Mã học sinh', data['studentCode']),
          ('Ngày sinh', data['dateOfBirth']),
          (
            'Giới tính',
            data['gender'] == 'FEMALE'
                ? 'Nữ'
                : data['gender'] == 'MALE'
                ? 'Nam'
                : data['gender'],
          ),
          ('Địa chỉ', data['address']),
          ('Phụ huynh', data['guardianName']),
          ('Số điện thoại', data['guardianPhone']),
          ('Email', data['email']),
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: widget.accent.withValues(alpha: .12),
              child: Icon(Icons.person_rounded, size: 38, color: widget.accent),
            ),
            const SizedBox(height: 12),
            Text(
              '${data['fullName'] ?? widget.student['fullName']}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            ...rows
                .where((row) => row.$2 != null && '${row.$2}'.isNotEmpty)
                .map(
                  (row) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      row.$1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    subtitle: Text(
                      '${row.$2}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
          ],
        );
      },
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

class _EmptyClass extends StatelessWidget {
  const _EmptyClass();

  @override
  Widget build(BuildContext context) => const _EmptyStudents(
    title: 'Chưa có lớp phụ trách',
    message: 'Liên hệ quản trị viên để kiểm tra phân công bộ môn.',
  );
}

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents({
    this.title = 'Chưa có học sinh',
    this.message = 'Danh sách học sinh sẽ xuất hiện sau khi được phân lớp.',
  });
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/illustrations/school-community-hero.png',
              width: 100,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
