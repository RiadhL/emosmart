import 'package:flutter/material.dart';
import '../models/game_level.dart';
import '../theme/app_theme.dart';

class LevelCard extends StatelessWidget {
  final GameLevel level;
  final VoidCallback? onTap;

  const LevelCard({super.key, required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final color = locked
        ? Colors.grey
        : _difficultyColor(level.difficulty);

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon or level number
              if (locked)
                const Icon(Icons.lock_rounded, size: 36, color: Colors.grey)
              else
                Text(
                  '${level.level}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              const SizedBox(height: 8),
              Text(level.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(level.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < level.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < level.stars ? AppTheme.secondary : Colors.grey.shade300,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(LevelDifficulty d) {
    switch (d) {
      case LevelDifficulty.easy: return AppTheme.primary;
      case LevelDifficulty.medium: return AppTheme.secondary;
      case LevelDifficulty.hard: return AppTheme.angryColor;
    }
  }
}
