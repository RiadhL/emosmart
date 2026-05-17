import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';

class ProgressScreen extends StatefulWidget {
  final String userId;
  final String childName;

  const ProgressScreen({
    super.key,
    required this.userId,
    this.childName = 'You',
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedGame = 'mood_match';
  bool   _loading      = true;

  Map<String, List<Map<String, int>>> _allSessions = {};
  StreamSubscription<DatabaseEvent>?  _subscription;
  StreamSubscription<User?>?          _authSub;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  String get _resolvedUid {
    if (widget.userId.isNotEmpty) return widget.userId;
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _startListening() {
    final uid = _resolvedUid;
    if (uid.isNotEmpty) {
      _setupDbListener(uid);
      return;
    }
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _authSub?.cancel();
        _authSub = null;
        _setupDbListener(user.uid);
      } else if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  void _setupDbListener(String uid) {
    print('Setting up Firebase listener for uid: $uid');
    _subscription?.cancel();
    _subscription = FirebaseDatabase.instance
        .ref('users/$uid/sessions')
        .onValue
        .listen(
      (event) {
        final result = <String, List<Map<String, int>>>{};

        if (event.snapshot.exists && event.snapshot.value is Map) {
          final data = event.snapshot.value as Map;
          for (final gameEntry in data.entries) {
            final gameId   = gameEntry.key.toString();
            final sessions = <Map<String, int>>[];

            if (gameEntry.value is Map) {
              (gameEntry.value as Map).forEach((_, raw) {
                if (raw is Map) {
                  sessions.add({
                    'score':       (raw['score']       as num?)?.toInt() ?? 0,
                    'errors':      (raw['errors']      as num?)?.toInt() ?? 0,
                    'duration':    (raw['duration']    as num?)?.toInt() ?? 0,
                    'level':       (raw['level']       as num?)?.toInt() ?? 1,
                    'timestamp':   (raw['timestamp']   as num?)?.toInt() ?? 0,
                    'totalRounds': (raw['totalRounds'] as num?)?.toInt() ?? 12,
                  });
                }
              });
            }
            sessions.sort((a, b) =>
                b['timestamp']!.compareTo(a['timestamp']!));
            result[gameId] = sessions;
          }
        }

        print('Sessions loaded: $result');
        if (mounted) setState(() { _allSessions = result; _loading = false; });
      },
      onError: (e) {
        print('Error loading sessions: $e');
        if (mounted) setState(() => _loading = false);
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  List<Map<String, int>> get _current => _allSessions[_selectedGame] ?? [];
  int    get _totalSessions => _current.length;
  int    get _bestScore     => _current.isEmpty ? 0
      : _current.map((s) => s['score']!).reduce(max);
  int    get _totalErrors   => _current.fold(0, (s, x) => s + x['errors']!);
  int    get _lastDuration  => _current.isEmpty ? 0 : _current.first['duration']!;

  String _fmtTime(int secs) {
    if (secs == 0) return '0m';
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  static const _games = [
    ('mood_match',      'Mood Match'),
    ('feeling_stories', 'Feeling Stories'),
    ('pattern_fun',     'Pattern Fun'),
  ];

  ({String label, Color color, String description}) _computeECT() {
    final all = <Map<String, int>>[];
    for (final sessions in _allSessions.values) {
      all.addAll(sessions);
    }

    if (all.isEmpty) {
      return (
        label: 'Not determined yet',
        color: AppTheme.textSecondary,
        description: 'Complete at least one game session to generate a clinical assessment.',
      );
    }

    final byLevel = <int, List<Map<String, int>>>{};
    for (final s in all) {
      final lvl = s['level'] ?? 1;
      byLevel.putIfAbsent(lvl, () => []).add(s);
    }

    bool mastered(int level) {
      final sessions = byLevel[level];
      if (sessions == null || sessions.isEmpty) return false;
      final avgAcc = sessions.map((s) {
        final total = s['totalRounds'] ?? 12;
        return total > 0 ? (s['score']! / total) * 100.0 : 0.0;
      }).reduce((a, b) => a + b) / sessions.length;
      return avgAcc >= 70.0;
    }

    final easy   = mastered(1);
    final medium = mastered(2);
    final hard   = mastered(3);

    if (!easy) {
      return (
        label: 'Pre-basic',
        color: const Color(0xFFE8604C),
        description: 'Child requires foundational emotion recognition intervention before progressing.',
      );
    }
    if (!medium) {
      return (
        label: 'Basic emotions',
        color: const Color(0xFFE8A030),
        description: 'Child consistently recognizes basic emotions. Ready to begin social emotion training.',
      );
    }
    if (!hard) {
      return (
        label: 'Social emotions',
        color: const Color(0xFF378ADD),
        description: 'Child demonstrates social emotion recognition. Complex emotion intervention recommended.',
      );
    }
    return (
      label: 'Complex emotions',
      color: const Color(0xFF3DAB7B),
      description: 'Child has mastered emotion recognition across all complexity levels.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.brandPurple),
        ),
      );
    }

    final sessions = _current;
    final last5    = sessions.take(5).toList().reversed.toList();

    return Column(
      children: [
        // ── Gradient header ──────────────────────────────────────────
        AnimatedEntrance(
          slideAxis: Axis.vertical,
          slideDistance: -20,
          child: ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: 160,
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
                    Positioned(top: -20, right: 20,
                      child: Container(width: 80, height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08)))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.childName}'s Progress",
                              style: GoogleFonts.poppins(
                                  fontSize: 22, fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Track emotion learning journey',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.75))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game selector tabs
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 100),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _games.map((g) {
                        final sel = _selectedGame == g.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGame = g.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: sel ? const LinearGradient(
                                colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                              ) : null,
                              color: sel ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? Colors.transparent
                                    : AppTheme.brandPurple.withOpacity(0.3),
                              ),
                              boxShadow: sel ? AppTheme.cardShadow : [],
                            ),
                            child: Text(g.$2,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : AppTheme.brandPurple)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Bar chart
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 180),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: sessions.isEmpty
                        ? SizedBox(
                            height: 140,
                            child: Center(
                              child: Text('No sessions yet',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary)),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last ${last5.length} session${last5.length == 1 ? '' : 's'} — score / 12',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 140,
                                child: BarChart(BarChartData(
                                  maxY: 12,
                                  barGroups: List.generate(last5.length, (i) {
                                    final shade = 0.4 + (i / last5.length) * 0.6;
                                    return BarChartGroupData(x: i, barRods: [
                                      BarChartRodData(
                                        toY: last5[i]['score']!.toDouble(),
                                        width: 28,
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            AppTheme.brandPurple.withOpacity(shade * 0.6),
                                            AppTheme.brandPurpleLight.withOpacity(shade),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, _) => Text(
                                          'S${v.toInt() + 1}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: AppTheme.textSecondary),
                                        ),
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                )),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // Stat cards
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 260),
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(
                          label: 'Sessions', value: '$_totalSessions',
                          gradient: AppTheme.primaryGradient,
                          icon: Icons.sports_esports_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(
                          label: 'Best score',
                          value: sessions.isEmpty ? '-' : '$_bestScore/12',
                          gradient: AppTheme.greenGradient,
                          icon: Icons.emoji_events_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(
                          label: 'Errors',
                          value: sessions.isEmpty ? '-' : '$_totalErrors',
                          gradient: AppTheme.coralGradient,
                          icon: Icons.close_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(
                          label: 'Last',
                          value: _fmtTime(_lastDuration),
                          gradient: AppTheme.amberGradient,
                          icon: Icons.timer_outlined)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // All games overview
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 340),
                  child: Text('All games',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                ),
                const SizedBox(height: 12),

                ..._games.map((g) {
                  final s     = _allSessions[g.$1] ?? [];
                  final best  = s.isEmpty ? 0
                      : s.map((x) => x['score']!).reduce(max);
                  final gradient = g.$1 == 'mood_match'
                      ? AppTheme.coralGradient
                      : g.$1 == 'feeling_stories'
                          ? AppTheme.amberGradient
                          : AppTheme.greenGradient;
                  return AnimatedEntrance(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GameProgressRow(
                        label: g.$2, sessions: s.length,
                        best: best, played: s.isNotEmpty,
                        gradient: gradient,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Clinical Assessment
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 480),
                  child: _EctCard(ect: _computeECT()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35);
    path.quadraticBezierTo(
        size.width / 2, size.height + 15, size.width, size.height - 35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_) => false;
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  final IconData icon;

  const _StatCard({required this.label, required this.value,
      required this.gradient, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 9, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Game progress row ─────────────────────────────────────────────────────────

class _GameProgressRow extends StatelessWidget {
  final String label;
  final int    sessions;
  final int    best;
  final bool   played;
  final LinearGradient gradient;

  const _GameProgressRow({required this.label, required this.sessions,
      required this.best, required this.played, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
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
              played
                  ? ShaderMask(
                      shaderCallback: (b) => gradient.createShader(b),
                      child: Text(
                        '$sessions session${sessions == 1 ? '' : 's'}  ·  best $best/12',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    )
                  : Text('No sessions yet',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          if (played) ...[
            const SizedBox(height: 10),
            Container(
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: gradient.colors.last.withOpacity(0.12),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: best / 12,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: gradient,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── ECT Card ──────────────────────────────────────────────────────────────────

class _EctCard extends StatelessWidget {
  final ({String label, Color color, String description}) ect;
  const _EctCard({required this.ect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.brandPurple.withOpacity(0.3), width: 2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🔬', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emotional Complexity Threshold (ECT)',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Clinical indicator — therapist use only',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppTheme.brandPurple,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppTheme.brandPurple.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ect.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ect.color.withOpacity(0.3)),
            ),
            child: Text(ect.label,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: ect.color)),
          ),
          const SizedBox(height: 12),
          Text(ect.description,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 10),
          Text(
            'ECT is calculated based on 70% accuracy threshold across all sessions',
            style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppTheme.brandPurple.withOpacity(0.7),
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
