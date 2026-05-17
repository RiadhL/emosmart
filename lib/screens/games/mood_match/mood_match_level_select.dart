import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/animated_entrance.dart';
import 'mood_match_game.dart';

class MoodMatchLevelSelect extends StatelessWidget {
  final String userId;
  const MoodMatchLevelSelect({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen coral gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)],
              ),
            ),
          ),
          // Decorative circles
          Positioned(top: -30, right: -30,
            child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08)))),
          Positioned(bottom: 80, left: -20,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06)))),

          SafeArea(
            child: Column(
              children: [
                // Header
                AnimatedEntrance(
                  slideAxis: Axis.vertical,
                  slideDistance: -20,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Mood Match',
                            style: GoogleFonts.poppins(
                                fontSize: 24, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 80),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 76),
                    child: Text('12 rounds per level',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.75))),
                  ),
                ),
                const SizedBox(height: 28),

                // Level buttons
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedEntrance(
                            delay: const Duration(milliseconds: 160),
                            child: _LevelCard(
                              number: '01',
                              label: 'Easy',
                              subtitle: 'Basic emotions',
                              badge: 'Level 1',
                              accentColor: const Color(0xFFFF6B6B),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      MoodMatchGame(level: 1, userId: userId))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: AnimatedEntrance(
                            delay: const Duration(milliseconds: 260),
                            child: _LevelCard(
                              number: '02',
                              label: 'Medium',
                              subtitle: 'Social emotions',
                              badge: 'Level 2',
                              accentColor: const Color(0xFFFF6B6B),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      MoodMatchGame(level: 2, userId: userId))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: AnimatedEntrance(
                            delay: const Duration(milliseconds: 360),
                            child: _LevelCard(
                              number: '03',
                              label: 'Hard',
                              subtitle: 'Complex emotions',
                              badge: 'Level 3',
                              accentColor: const Color(0xFFFF6B6B),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      MoodMatchGame(level: 3, userId: userId))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedEntrance(
                          delay: const Duration(milliseconds: 440),
                          child: Text(
                            'Complete all levels to get your final score!',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtitle;
  final String badge;
  final Color accentColor;
  final VoidCallback onTap;

  const _LevelCard({
    required this.number,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.92),
                    Colors.white.withOpacity(0.78),
                  ],
                ),
                border: Border.all(
                    color: Colors.white.withOpacity(0.85), width: 1.5),
              ),
              child: Row(
                children: [
                  // Big level number
                  Text(number,
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.w900,
                          color: accentColor.withOpacity(0.25))),
                  const SizedBox(width: 16),

                  // Title & subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),

                  // Badge pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.8),
                          accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(badge,
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.white)),
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
