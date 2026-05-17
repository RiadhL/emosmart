import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _letterSpacing;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _buttonsSlide;
  late Animation<double> _buttonsOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _lineOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic)));

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic)));

    _letterSpacing = Tween<double>(begin: -15.0, end: 1.5).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.15, 0.65, curve: Curves.easeOutExpo)));

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)));

    _buttonsSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller,
                curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic)));

    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.65, 1.0)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEE9FF), Color(0xFFF8F7FF)],
              ),
            ),
          ),

          // ── Decorative circles ───────────────────────────────────────
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFA78BFA).withOpacity(0.15),
                    const Color(0xFF7C6FF7).withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80, left: -30,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B9D).withOpacity(0.10),
                    const Color(0xFFD4538A).withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            right: 40,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF56CFB2).withOpacity(0.08),
                    const Color(0xFF3DAB7B).withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Accent line
                  FadeTransition(
                    opacity: _lineOpacity,
                    child: Container(
                      width: 50, height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated title
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleOpacity.value,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Emo',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 120, 60),
                                    ),
                                  letterSpacing: _letterSpacing.value,
                                ),
                              ),
                              TextSpan(
                                text: 'Smart',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A2E),
                                  letterSpacing: _letterSpacing.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Learn emotions through play',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6B8A),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  SlideTransition(
                    position: _buttonsSlide,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: Column(
                        children: [
                          // "I'm new here" — gradient button
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5B4FCF).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "I'm new here",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // "I already have an account" — glass style
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const LoginScreen())),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white.withOpacity(0.9),
                                border: Border.all(
                                    color: const Color(0xFFA78BFA), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'I already have an account',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5B4FCF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _buttonsOpacity,
                    child: Text(
                      'EmoSmart · Made for curious kids',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: const Color(0xFF9999AA)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
