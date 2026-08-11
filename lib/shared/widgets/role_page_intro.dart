import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RolePageIntro extends StatelessWidget {
  const RolePageIntro({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    this.badges = const [],
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final List<String> badges;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, Color.lerp(accent, Colors.black, .22)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .2),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    DateFormat('dd/MM').format(DateTime.now()),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
                )),
            const SizedBox(height: 5),
            Text(subtitle,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.4)),
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges
                    .map((badge) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .13),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(badge,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      );
}
