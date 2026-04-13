import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'pattern_fun_game.dart';

class PatternFunLevelSelect extends StatelessWidget {
  final String userId;
  const PatternFunLevelSelect({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pattern Fun'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose your level',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              const Text('12 rounds per level',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 28),

              _LevelButton(
                label: 'Easy',
                subtitle: 'AB patterns · 4 choices',
                badge: 'Level 1',
                bg: const Color(0xFFE4F5ED),
                border: const Color(0xFF80D4A8),
                labelColor: const Color(0xFF1A7A50),
                badgeBg: const Color(0xFF80D4A8),
                badgeText: const Color(0xFF0A4A28),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PatternFunGame(level: 1, userId: userId))),
              ),
              const SizedBox(height: 12),

              _LevelButton(
                label: 'Medium',
                subtitle: 'ABC patterns · size variation',
                badge: 'Level 2',
                bg: const Color(0xFFFDF3E3),
                border: const Color(0xFFF0C870),
                labelColor: const Color(0xFFA06010),
                badgeBg: const Color(0xFFF0C870),
                badgeText: const Color(0xFF603808),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PatternFunGame(level: 2, userId: userId))),
              ),
              const SizedBox(height: 12),

              _LevelButton(
                label: 'Hard',
                subtitle: 'AABB patterns · two-slot missing',
                badge: 'Level 3',
                bg: const Color(0xFFFDECEA),
                border: const Color(0xFFF0A090),
                labelColor: const Color(0xFFA03020),
                badgeBg: const Color(0xFFF0A090),
                badgeText: const Color(0xFF601808),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PatternFunGame(level: 3, userId: userId))),
              ),

              const Spacer(),
              const Center(
                child: Text(
                  'Complete all levels to get your final score!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final String badge;
  final Color bg;
  final Color border;
  final Color labelColor;
  final Color badgeBg;
  final Color badgeText;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label, required this.subtitle, required this.badge,
    required this.bg, required this.border, required this.labelColor,
    required this.badgeBg, required this.badgeText, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold,
                          color: labelColor)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(20)),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: badgeText)),
            ),
          ],
        ),
      ),
    );
  }
}
