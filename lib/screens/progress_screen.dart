import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/game_result.dart';
import '../services/game_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  final String userId;
  final String childName;

  const ProgressScreen({
    super.key,
    required this.userId,
    this.childName = 'You',
  });

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return _ProgressBody(
        recent: [], mm: [], fs: [], pf: [], childName: childName,
      );
    }

    return FutureBuilder<_AllResults>(
      future: _loadAll(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.brandPurple));
        }
        final data = snap.data ??
            _AllResults(recent: [], mm: [], fs: [], pf: []);
        return _ProgressBody(
          recent:    data.recent,
          mm:        data.mm,
          fs:        data.fs,
          pf:        data.pf,
          childName: childName,
        );
      },
    );
  }

  static Future<_AllResults> _loadAll(String uid) async {
    final gs = GameService();
    final results = await Future.wait([
      gs.getResultsForGame(uid, 'mood_match'),
      gs.getResultsForGame(uid, 'feeling_stories'),
      gs.getResultsForGame(uid, 'pattern_fun'),
    ]);
    final mm = results[0];
    final fs = results[1];
    final pf = results[2];

    final all = [...mm, ...fs, ...pf]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final recent = all.take(5).toList();

    return _AllResults(recent: recent, mm: mm, fs: fs, pf: pf);
  }
}

class _AllResults {
  final List<GameResult> recent;
  final List<GameResult> mm;
  final List<GameResult> fs;
  final List<GameResult> pf;
  _AllResults({required this.recent, required this.mm, required this.fs, required this.pf});
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ProgressBody extends StatelessWidget {
  final List<GameResult> recent;
  final List<GameResult> mm;
  final List<GameResult> fs;
  final List<GameResult> pf;
  final String childName;

  const _ProgressBody({
    required this.recent,
    required this.mm,
    required this.fs,
    required this.pf,
    required this.childName,
  });

  // ── Computed stats ──────────────────────────────────────────────────────────

  List<double> get _barValues {
    if (recent.isEmpty) return [];
    return recent.reversed
        .map((r) => r.maxScore > 0 ? (r.score / r.maxScore) * 12 : 0.0)
        .toList();
  }

  int get _bestScore {
    if (recent.isEmpty) return 0;
    return recent
        .map((r) => r.score)
        .reduce((a, b) => a > b ? a : b);
  }

  int get _errorsToday {
    final today = DateTime.now();
    return [...mm, ...fs, ...pf]
        .where((r) =>
            r.completedAt.year  == today.year &&
            r.completedAt.month == today.month &&
            r.completedAt.day   == today.day)
        .fold(0, (sum, r) => sum + r.errors);
  }

  String get _timeToday {
    final today = DateTime.now();
    final secs = [...mm, ...fs, ...pf]
        .where((r) =>
            r.completedAt.year  == today.year &&
            r.completedAt.month == today.month &&
            r.completedAt.day   == today.day)
        .fold(0, (sum, r) => sum + r.timeTaken.inSeconds);
    if (secs == 0) return '0m';
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  int _gameScore(List<GameResult> results) =>
      results.fold(0, (sum, r) => sum + r.score);

  @override
  Widget build(BuildContext context) {
    final bars = _barValues;
    final mmScore = _gameScore(mm);
    final fsScore = _gameScore(fs);
    final pfScore = _gameScore(pf);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$childName's progress",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('Last 5 sessions',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            // ── Bar chart ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: bars.isEmpty
                  ? const SizedBox(
                      height: 140,
                      child: Center(
                        child: Text('No sessions yet',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: BarChart(BarChartData(
                            maxY: 12,
                            barGroups: List.generate(bars.length, (i) {
                              final shade = 0.4 + (i / bars.length) * 0.6;
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: bars[i],
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                  color: AppTheme.brandPurple
                                      .withValues(alpha: shade),
                                ),
                              ]);
                            }),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) => Text(
                                    'S${v.toInt() + 1}',
                                    style: const TextStyle(
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
                        const SizedBox(height: 6),
                        Text(
                          bars.length > 1 ? 'Score improving ↑' : 'Keep playing!',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // ── Stat cards ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _StatCard(
                    label: 'Best score',
                    value: '$_bestScore',
                    color: AppTheme.brandPurple)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                    label: 'Errors today',
                    value: '$_errorsToday',
                    color: AppTheme.coral)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                    label: 'Time today',
                    value: _timeToday,
                    color: AppTheme.green)),
              ],
            ),

            const SizedBox(height: 20),

            // ── All games ───────────────────────────────────────────────
            const Text('All games',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 12),

            _GameProgressRow(
              label: 'Mood Match',
              score: mmScore,
              max: 36,
              played: mm.isNotEmpty,
              color: AppTheme.coral,
            ),
            const SizedBox(height: 10),
            _GameProgressRow(
              label: 'Feeling Stories',
              score: fsScore,
              max: 36,
              played: fs.isNotEmpty,
              color: AppTheme.amber,
            ),
            const SizedBox(height: 10),
            _GameProgressRow(
              label: 'Pattern Fun',
              score: pfScore,
              max: 36,
              played: pf.isNotEmpty,
              color: AppTheme.green,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Game progress row ─────────────────────────────────────────────────────────

class _GameProgressRow extends StatelessWidget {
  final String label;
  final int    score;
  final int    max;
  final bool   played;
  final Color  color;

  const _GameProgressRow({
    required this.label,
    required this.score,
    required this.max,
    required this.played,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              played
                  ? Text('$score / $max',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color))
                  : const Text('No sessions yet',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary)),
            ],
          ),
          if (played) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: max > 0 ? score / max : 0,
                minHeight: 7,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
