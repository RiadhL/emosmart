import 'dart:math' show pow;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Exponential ease-out curve (CSS equivalent: cubic-bezier(0.16,1,0.3,1))
class _EaseOutExpo extends Curve {
  const _EaseOutExpo();
  @override
  double transform(double t) {
    if (t == 0) return 0;
    if (t == 1) return 1;
    return 1.0 - pow(2.0, -10.0 * t).toDouble();
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lineCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _buttonsCtrl;

  late final Animation<double> _lineFade;
  late final Animation<double> _letterSpacing; // -12 → 0
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _buttonsSlide;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();

    _lineCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _titleCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _taglineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _buttonsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    _lineFade = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeIn);

    _letterSpacing = Tween<double>(begin: -12.0, end: 0.0)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: const _EaseOutExpo()));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn));

    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);

    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _buttonsCtrl, curve: const _EaseOutExpo()));
    _buttonsFade = CurvedAnimation(parent: _buttonsCtrl, curve: Curves.easeIn);

    // Stagger: line 0ms, title 200ms, tagline 600ms, buttons 800ms
    _lineCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _titleCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _taglineCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _buttonsCtrl.forward(); });
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _buttonsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── Thin purple line ─────────────────────────────────────────
              FadeTransition(
                opacity: _lineFade,
                child: Container(
                  width: 40,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPurple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Title with letter-spread ─────────────────────────────────
              FadeTransition(
                opacity: _titleFade,
                child: AnimatedBuilder(
                  animation: _letterSpacing,
                  builder: (_, __) => RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Emo',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandPurple,
                            letterSpacing: _letterSpacing.value,
                          ),
                        ),
                        TextSpan(
                          text: 'Smart',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: _letterSpacing.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tagline ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'Learn emotions through play',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Buttons ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _buttonsFade,
                child: SlideTransition(
                  position: _buttonsSlide,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: const Text("I'm new here"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.brandLightPurple,
                            foregroundColor: AppTheme.brandPurple,
                            side: const BorderSide(color: Color(0xFF8B80E0), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                            ),
                          ),
                          child: const Text('I already have an account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Footer ───────────────────────────────────────────────────
              FadeTransition(
                opacity: _buttonsFade,
                child: const Text(
                  'EmoSmart · Made for curious kids',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9999AA)),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
