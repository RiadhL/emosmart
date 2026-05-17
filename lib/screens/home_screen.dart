import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';
import 'progress_screen.dart';
import 'facial_expression_screen.dart';
import 'welcome_screen.dart';
import 'games/mood_match/mood_match_level_select.dart';
import 'games/feeling_stories/feeling_stories_level_select.dart';
import 'games/pattern_fun/pattern_fun_level_select.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile? profile;
  const HomeScreen({super.key, this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final uid  = widget.profile?.uid  ?? '';
    final name = widget.profile?.name ?? 'there';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _tab,
        children: [
          _GamesTab(name: name, uid: uid),
          ProgressScreen(userId: uid, childName: name),
          const FacialExpressionScreen(),
        ],
      ),
      bottomNavigationBar: _EmoBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Games Tab ─────────────────────────────────────────────────────────────────

class _GamesTab extends StatelessWidget {
  final String name;
  final String uid;
  const _GamesTab({required this.name, required this.uid});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Gradient header with curved bottom ────────────────────────
        _CurvedHeader(name: name, onLogout: () => _logout(context)),

        // ── Game cards ───────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: _GameCard(
                    gradient: AppTheme.coralGradient,
                    emoji: '😊',
                    title: 'Mood Match',
                    subtitle: 'Find the emotion',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => MoodMatchLevelSelect(userId: uid))),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 300),
                  child: _GameCard(
                    gradient: AppTheme.amberGradient,
                    emoji: '📖',
                    title: 'Feeling Stories',
                    subtitle: 'Choose the feeling',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                FeelingStoriesLevelSelect(userId: uid))),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 400),
                  child: _GameCard(
                    gradient: AppTheme.greenGradient,
                    emoji: '🧩',
                    title: 'Pattern Fun',
                    subtitle: 'Complete patterns',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PatternFunLevelSelect(userId: uid))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Curved gradient header ────────────────────────────────────────────────────

class _CurvedHeader extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  const _CurvedHeader({required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 190,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Decorative small circles inside header
              Positioned(top: 10, right: 30,
                child: Container(width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ))),
              Positioned(top: 40, right: 80,
                child: Container(width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ))),
              Positioned(bottom: 50, left: 20,
                child: Container(width: 45, height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ))),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AnimatedEntrance(
                        delay: const Duration(milliseconds: 100),
                        slideAxis: Axis.horizontal,
                        slideDistance: -20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hello, $name 👋',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Let's play\nand learn!",
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                        ),
                        child: Icon(Icons.logout_rounded,
                            color: Colors.white.withOpacity(0.9), size: 18),
                      ),
                      tooltip: 'Sign out',
                      onPressed: onLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height + 20,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ── Game card ─────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final LinearGradient gradient;
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GameCard({
    required this.gradient,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.92),
                    Colors.white.withOpacity(0.75),
                  ],
                ),
                border: Border.all(
                    color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: Row(
                children: [
                  // Left gradient square with emoji
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.last.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),

                  // Arrow circle with gradient
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white),
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

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _EmoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _EmoBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4FCF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Games',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.show_chart_rounded,
                label: 'Progress',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.face_retouching_natural,
                label: 'Camera',
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                ).createShader(bounds),
                child: Icon(icon, size: 24, color: Colors.white),
              )
            else
              Icon(icon, size: 24, color: const Color(0xFF9999AA)),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppTheme.brandPurple : const Color(0xFF9999AA),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 6 : 0,
              height: active ? 6 : 0,
              decoration: BoxDecoration(
                gradient: active ? const LinearGradient(
                  colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                ) : null,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
