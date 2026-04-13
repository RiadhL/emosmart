import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class FinalScoreScreen extends StatelessWidget {
  final String gameTitle;
  final int    level;
  final int    score;
  final int    maxScore;
  final int    timeSecs;
  final String userId;

  const FinalScoreScreen({
    super.key,
    required this.gameTitle,
    required this.level,
    required this.score,
    required this.maxScore,
    required this.timeSecs,
    required this.userId,
  });

  String get _timeStr {
    final m = (timeSecs ~/ 60).toString().padLeft(2, '0');
    final s = (timeSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _levelName {
    switch (level) {
      case 1: return 'Easy';
      case 2: return 'Medium';
      case 3: return 'Hard';
      default: return 'Level $level';
    }
  }

  Color get _levelBarColor {
    switch (level) {
      case 1: return AppTheme.green;
      case 2: return AppTheme.amber;
      case 3: return AppTheme.coral;
      default: return AppTheme.brandPurple;
    }
  }

  int get _starsEarned {
    final pct = score / maxScore;
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    if (pct >= 0.3) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final stars = _starsEarned;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Purple trophy card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.brandPurple,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        size: 48, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text('Well done!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('$score / $maxScore',
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Total across all rounds',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBC8F0))),
                    const SizedBox(height: 14),
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: i < stars
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF9B97D4),
                        ),
                      )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Score breakdown ───────────────────────────────────────
              const Text('Score breakdown',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 14),

              _ScoreRow(
                label: '$_levelName · $gameTitle',
                color: _levelBarColor,
                value: score,
                max:   maxScore,
              ),

              const SizedBox(height: 6),

              // Time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.brandLightPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppTheme.brandPurple),
                    const SizedBox(width: 8),
                    const Text('Time taken',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.brandPurple)),
                    const Spacer(),
                    Text(_timeStr,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandPurple)),
                  ],
                ),
              ),

              const Spacer(),

              // ── Buttons ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.popUntil(
                            context, (r) => r.isFirst),
                        child: const Text('Play again'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => HomeScreen(profile: null)),
                          (_) => false,
                        ),
                        child: const Text('Home →'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final Color  color;
  final int    value;
  final int    max;

  const _ScoreRow({
    required this.label,
    required this.color,
    required this.value,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Text('$value / $max',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: max > 0 ? value / max : 0,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
