import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'mood_match/mood_match_level_select.dart';
import 'feeling_stories/feeling_stories_level_select.dart';
import 'pattern_fun/pattern_fun_level_select.dart';

class GamesHubScreen extends StatelessWidget {
  final String userId;

  const GamesHubScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a game!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Learn emotions while having fun 🎉',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: const Color(0xFF6B7280))),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: [
                  _GameTile(
                    emoji: '🃏',
                    title: 'Mood Match',
                    subtitle: 'Match emotion cards together',
                    color: AppTheme.primary,
                    badge: 'Memory',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MoodMatchLevelSelect(userId: userId)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GameTile(
                    emoji: '📖',
                    title: 'Feeling Stories',
                    subtitle: 'Read a story and find the emotion',
                    color: AppTheme.secondary,
                    badge: 'Reading',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FeelingStoriesLevelSelect(userId: userId)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GameTile(
                    emoji: '🔮',
                    title: 'Pattern Fun',
                    subtitle: 'Complete the emotion pattern',
                    color: AppTheme.surprisedColor,
                    badge: 'Logic',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PatternFunLevelSelect(userId: userId)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final String badge;
  final VoidCallback onTap;

  const _GameTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
