import 'package:flutter/material.dart';
import '../models/emotion.dart';
import '../theme/app_theme.dart';

class EmotionCard extends StatelessWidget {
  final Emotion emotion;
  final VoidCallback? onTap;
  final bool selected;

  const EmotionCard({
    super.key,
    required this.emotion,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.emotionColor(emotion.id);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.3) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: color, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              emotion.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
