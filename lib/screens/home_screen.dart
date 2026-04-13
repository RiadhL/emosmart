import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
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

// ── Games Tab ────────────────────────────────────────────────────────────────

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
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name 👋',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Let's play",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandPurple,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'and learn!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandPurple,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout button
                IconButton(
                  icon: const Icon(Icons.logout,
                      color: AppTheme.textSecondary, size: 20),
                  tooltip: 'Sign out',
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Game cards — fill remaining space ─────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _GameCard(
                    bg:          const Color(0xFFFDECEA),
                    border:      const Color(0xFFF0A090),
                    iconBg:      const Color(0xFFFFDADD),
                    iconEmoji:   '😊',
                    accentColor: const Color(0xFFE8604C),
                    title:       'Mood Match',
                    subtitle:    'Find the emotion',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => MoodMatchLevelSelect(userId: uid))),
                  ),
                  _GameCard(
                    bg:          const Color(0xFFFDF3E3),
                    border:      const Color(0xFFF0C870),
                    iconBg:      const Color(0xFFFDECC8),
                    iconEmoji:   '📖',
                    accentColor: const Color(0xFFE8A030),
                    title:       'Feeling Stories',
                    subtitle:    'Choose the feeling',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                FeelingStoriesLevelSelect(userId: uid))),
                  ),
                  _GameCard(
                    bg:          const Color(0xFFE4F5ED),
                    border:      const Color(0xFF80D4A8),
                    iconBg:      const Color(0xFFC8EFD8),
                    iconEmoji:   '🧩',
                    accentColor: const Color(0xFF3DAB7B),
                    title:       'Pattern Fun',
                    subtitle:    'Complete patterns',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PatternFunLevelSelect(userId: uid))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color iconBg;
  final String iconEmoji;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GameCard({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconEmoji,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: border.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(iconEmoji,
                    style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 18, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Bottom Navigation Bar ─────────────────────────────────────────────

class _EmoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _EmoBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
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
                label: 'Facial expression',
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
    final color = active ? AppTheme.brandPurple : const Color(0xFF9999AA);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  active ? 6 : 0,
              height: active ? 6 : 0,
              decoration: BoxDecoration(
                color: AppTheme.brandPurple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
