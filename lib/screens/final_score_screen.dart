import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';

class FinalScoreScreen extends StatefulWidget {
  final String        gameTitle;
  final int           level;
  final int           score;
  final int           errors;
  final int           maxScore;
  final int           timeSecs;
  final String        userId;
  final WidgetBuilder? nextLevelBuilder;

  const FinalScoreScreen({
    super.key,
    required this.gameTitle,
    required this.level,
    required this.score,
    required this.errors,
    required this.maxScore,
    required this.timeSecs,
    required this.userId,
    this.nextLevelBuilder,
  });

  @override
  State<FinalScoreScreen> createState() => _FinalScoreScreenState();
}

class _FinalScoreScreenState extends State<FinalScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  String get _timeStr {
    final m = (widget.timeSecs ~/ 60).toString().padLeft(2, '0');
    final s = (widget.timeSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _levelName {
    switch (widget.level) {
      case 1: return 'Easy';
      case 2: return 'Medium';
      case 3: return 'Hard';
      default: return 'Level ${widget.level}';
    }
  }

  LinearGradient get _gameGradient {
    if (widget.gameTitle.contains('Mood')) return AppTheme.coralGradient;
    if (widget.gameTitle.contains('Stories')) return AppTheme.amberGradient;
    if (widget.gameTitle.contains('Pattern')) return AppTheme.greenGradient;
    return AppTheme.primaryGradient;
  }

  Color get _levelBarColor {
    switch (widget.level) {
      case 1: return AppTheme.green;
      case 2: return AppTheme.amber;
      case 3: return AppTheme.coral;
      default: return AppTheme.brandPurple;
    }
  }

  int get _starsEarned {
    final pct = widget.score / widget.maxScore;
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    if (pct >= 0.3) return 1;
    return 0;
  }

  void _goHome(BuildContext context) {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    final stars       = _starsEarned;
    final isLastLevel = widget.nextLevelBuilder == null;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen gradient matching game color
          Container(
            decoration: BoxDecoration(gradient: _gameGradient),
          ),
          // Decorative circles
          Positioned(top: -40, right: -40,
            child: Container(width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08)))),
          Positioned(bottom: 100, left: -30,
            child: Container(width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06)))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // ── Trophy & Score ─────────────────────────────────
                  AnimatedEntrance(
                    child: Column(
                      children: [
                        // Bouncing trophy
                        AnimatedBuilder(
                          animation: _bounce,
                          builder: (_, child) => Transform.scale(
                            scale: _bounce.value,
                            child: child,
                          ),
                          child: const Text('🏆',
                              style: TextStyle(fontSize: 64)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Well done ${widget.userId.isEmpty ? "" : "!"}',
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.score} / ${widget.maxScore}',
                          style: GoogleFonts.poppins(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${widget.level} complete! — $_levelName',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8)),
                        ),
                        if (isLastLevel) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('🏆  All levels complete!',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedEntrance(
                              delay: Duration(milliseconds: 400 + i * 150),
                              child: Icon(
                                i < stars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 36,
                                color: i < stars
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Score breakdown card ───────────────────────────
                  Expanded(
                    child: AnimatedEntrance(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white.withOpacity(0.95),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score breakdown',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 14),

                            _ScoreRow(
                              label: '$_levelName · ${widget.gameTitle}',
                              color: _levelBarColor,
                              value: widget.score,
                              max:   widget.maxScore,
                            ),
                            const SizedBox(height: 8),

                            _InfoRow(
                              icon: Icons.close_rounded,
                              color: AppTheme.coral,
                              label: 'Errors',
                              value: '${widget.errors}',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.timer_outlined,
                              color: AppTheme.brandPurple,
                              label: 'Time taken',
                              value: _timeStr,
                            ),

                            const Spacer(),

                            // Buttons
                            if (!isLastLevel) ...[
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: widget.nextLevelBuilder!),
                                ),
                                child: Container(
                                  width: double.infinity, height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _gameGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gameGradient.colors.last
                                            .withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text('Next level  →',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity, height: 52,
                                child: OutlinedButton(
                                  onPressed: () => _goHome(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: _gameGradient.colors.last,
                                        width: 1.5),
                                    foregroundColor: _gameGradient.colors.last,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text('Go home',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: () => _goHome(context),
                                child: Container(
                                  width: double.infinity, height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _gameGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gameGradient.colors.last
                                            .withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text('Go home 🏠',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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

// ── Score row ─────────────────────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  final String label;
  final Color  color;
  final int    value;
  final int    max;

  const _ScoreRow({required this.label, required this.color,
      required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Text('$value / $max',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withOpacity(0.15)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: max > 0 ? value / max : 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;

  const _InfoRow({required this.icon, required this.color,
      required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
