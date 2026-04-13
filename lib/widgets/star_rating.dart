import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final int stars;      // 0-3
  final double size;

  const StarRating({super.key, required this.stars, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('star_${stars}_$i'),
          tween: Tween(begin: 0.5, end: i < stars ? 1.0 : 0.5),
          duration: Duration(milliseconds: 300 + i * 120),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars ? AppTheme.secondary : Colors.grey.shade300,
            size: size,
          ),
        );
      }),
    );
  }
}

/// Full-screen level-complete panel shown after a game finishes.
class LevelCompletePanel extends StatelessWidget {
  final int stars;
  final int score;
  final int maxScore;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const LevelCompletePanel({
    super.key,
    required this.stars,
    required this.score,
    required this.maxScore,
    required this.onNext,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Level Complete!',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              StarRating(stars: stars, size: 52),
              const SizedBox(height: 16),
              Text(
                '$score / $maxScore',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onHome,
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Level'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
