import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class ExamCategoriesPage extends StatelessWidget {
  const ExamCategoriesPage({super.key});

  static const _categories = [
    ('ORAL', 'Điểm miệng', 1.0, 4),
    ('15M', 'Bài 15 phút', 1.0, 4),
    ('MID', 'Giữa kỳ', 2.0, 1),
    ('FINAL', 'Cuối kỳ', 3.0, 1),
  ];

  static const _coefficients = [
    ('Toán', 2.0),
    ('Vật lý', 1.5),
    ('Hóa học', 1.5),
    ('Sinh học', 1.0),
    ('Ngữ văn', 2.0),
    ('Tiếng Anh', 1.5),
    ('Lịch sử', 1.0),
    ('Địa lý', 1.0),
    ('GDCD', 1.0),
    ('Thể dục', 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cấu hình Khảo thí'),
          backgroundColor: AppColors.adminAccent,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Loại điểm'),
              Tab(text: 'Hệ số môn'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategories(context),
            _buildCoefficients(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.adminAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.adminAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trọng số nhân với điểm số khi tính TB môn. '
                  'Max count = giới hạn số lần nhập mỗi HS/HK.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Năm học 2025-2026',
          action: 'Thêm loại điểm',
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < _categories.length; i++) ...[
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.adminAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(_categories[i].$1,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.adminAccent)),
                    ),
                  ),
                  title: Text(_categories[i].$2,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text(
                      'Hệ số: ${_categories[i].$3.toStringAsFixed(1)} • Max ${_categories[i].$4} lần/HK',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.textSecondary),
                  onTap: () {},
                ),
                if (i < _categories.length - 1) const Divider(height: 0),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(title: 'Công thức tính TB môn'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TB môn = (ΣM + Σ15p + 2×GK + 3×CK) / (số bài + 2 + 3)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                SizedBox(height: 6),
                Text(
                  'TB năm = (TB HK1 + 2 × TB HK2) / 3',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoefficients(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(title: 'Hệ số môn — Năm 2025-2026'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < _coefficients.length; i++) ...[
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _coefficients[i].$2 >= 1.5
                          ? AppColors.adminAccent.withOpacity(0.12)
                          : AppColors.textSecondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _coefficients[i].$2.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _coefficients[i].$2 >= 1.5
                                ? AppColors.adminAccent
                                : AppColors.textSecondary),
                      ),
                    ),
                  ),
                  title: Text(_coefficients[i].$1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text(
                    _coefficients[i].$2 >= 1.5
                        ? 'Môn chính'
                        : 'Môn phụ',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.textSecondary),
                  onTap: () {},
                ),
                if (i < _coefficients.length - 1) const Divider(height: 0),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
