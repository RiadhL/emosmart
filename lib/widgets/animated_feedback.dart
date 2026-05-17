c:\Users\MED\OneDrive\Imagens\Screenshots 1\2026-04-30.pngimport 'package:flutter/material.dart';

/// Wraps a child with a pop-in scale + fade animation.
/// Use as a wrapper when you want to celebrate a correct answer or new result.
class AnimatedFeedback extends StatefulWidget {
  final Widget child;

  const AnimatedFeedback({super.key, required this.child});

  @override
  State<AnimatedFeedback> createState() => _AnimatedFeedbackState();
}

class _AnimatedFeedbackState extends State<AnimatedFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Full-screen overlay shown on correct / wrong answer.
class FeedbackOverlay extends StatelessWidget {
  final bool correct;
  final String message;
  final VoidCallback onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.correct,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
    final emoji = correct ? '🎉' : '😅';

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black45,
        child: Center(
          child: AnimatedFeedback(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(
                    correct ? 'Correct! 🌟' : 'Try Again!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, height: 1.5)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onDismiss,
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    child: Text(correct ? 'Keep Going!' : 'Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
