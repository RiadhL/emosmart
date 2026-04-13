import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressBadge extends StatelessWidget {
  final int totalSessions;
  final int streak;

  const ProgressBadge({
    super.key,
    required this.totalSessions,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(icon: '⭐', value: totalSessions, label: 'Sessions'),
        const SizedBox(width: 16),
        _Badge(icon: '🔥', value: streak, label: 'Streak'),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon;
  final int value;
  final String label;

  const _Badge({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          Text('$value',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
