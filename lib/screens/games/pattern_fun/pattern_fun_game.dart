import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/emotion.dart';
import '../../../services/audio_service.dart';
import '../../../theme/app_theme.dart';
import '../../final_score_screen.dart';

// ── Pattern question model ────────────────────────────────────────────────────

class _PQ {
  final List<String>  shown;
  final List<double>  shownSz;
  final List<String>  blanks;
  final List<String>  choices;
  final bool          twoSlot;
  final String        question;

  _PQ({
    required this.shown, required this.shownSz,
    required this.blanks, required this.choices,
    required this.twoSlot, required this.question,
  });
}

List<_PQ> _buildQuestions(int level, Random rng) {
  final eIds  = Emotion.forGameLevel(level).map((e) => e.id).toList();

  _PQ makeAB(String a, String b) {
    final shown = [a, b, a, b, a];
    final ans   = b;
    final others = eIds.where((x) => x != a && x != b).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(shown: shown, shownSz: List.filled(shown.length, 28),
        blanks: [ans], choices: choices, twoSlot: false, question: 'What comes next?');
  }

  _PQ makeABC(String a, String b, String c) {
    final shown = [a, b, c, a, b, c, a, b];
    final ans   = c;
    final others = eIds.where((x) => x != a && x != b && x != c).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(shown: shown, shownSz: List.filled(shown.length, 26),
        blanks: [ans], choices: choices, twoSlot: false, question: 'What comes next?');
  }

  _PQ makeSize(String a, String b) {
    final shown  = [a, a, a, b, b, b, a, a, a, b, b, b];
    final sizes  = [36.0, 22.0, 22.0, 36.0, 22.0, 22.0, 36.0, 22.0, 22.0, 36.0, 22.0, 22.0];
    final ans = a;
    final others = eIds.where((x) => x != a && x != b).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(shown: shown, shownSz: sizes, blanks: [ans], choices: choices,
        twoSlot: false, question: 'What comes next?');
  }

  _PQ makeAABB(String a, String b) {
    final shown = [a, a, b, b, a, a, b, b];
    final pairs = ['$a|$a', '$b|$b', '$a|$b', '$b|$a']..shuffle(rng);
    return _PQ(shown: shown, shownSz: List.filled(shown.length, 26),
        blanks: [a, a], choices: pairs, twoSlot: true,
        question: 'Complete the missing pair');
  }

  final qs = <_PQ>[];
  final pool = [...eIds]..shuffle(rng);

  for (int i = 0; i < 12; i++) {
    final a = pool[i % pool.length];
    final b = pool[(i + 1) % pool.length];
    final c = pool[(i + 2) % pool.length];

    if (level == 1) qs.add(makeAB(a, b));
    if (level == 2) {
      if (i % 2 == 0) { qs.add(makeABC(a, b, c)); }
      else { qs.add(makeSize(a, b)); }
    }
    if (level == 3) qs.add(makeAABB(a, b));
  }
  return qs;
}

// ── Game screen ───────────────────────────────────────────────────────────────

class PatternFunGame extends StatefulWidget {
  final int level;
  final String userId;
  const PatternFunGame({super.key, required this.level, required this.userId});

  @override
  State<PatternFunGame> createState() => _PatternFunGameState();
}

class _PatternFunGameState extends State<PatternFunGame> {
  static const int totalRounds = 12;

  late final List<_PQ> _questions;
  int _round  = 0;
  int _score  = 0;
  int _errors = 0;
  String? _selected;
  bool _answered = false;

  int _seconds = 0;
  Timer? _timer;

  final _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.level, Random());
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _seconds++); });
  }

  _PQ get _current => _questions[_round];

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _answer(String choice) async {
    if (_answered) return;
    final correct = _isCorrect(choice);
    setState(() { _selected = choice; _answered = true; if (correct) {
      _score++;
    } else {
      _errors++;
    } });
    await _audio.playFeedback(correct: correct);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_round < totalRounds - 1) {
      setState(() { _round++; _selected = null; _answered = false; });
    } else {
      _finish();
    }
  }

  bool _isCorrect(String choice) {
    final q = _current;
    if (q.twoSlot) {
      final parts = choice.split('|');
      return parts.length == q.blanks.length &&
          List.generate(q.blanks.length, (i) => parts[i] == q.blanks[i])
              .every((x) => x);
    }
    return choice == q.blanks.first;
  }

  void _finish() {
    _timer?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final data = {
        'score':       _score,
        'errors':      _errors,
        'duration':    _seconds,
        'level':       widget.level,
        'timestamp':   DateTime.now().millisecondsSinceEpoch,
        'totalRounds': totalRounds,
        'gameId':      'pattern_fun',
      };
      FirebaseDatabase.instance
          .ref('users/${user.uid}/sessions/pattern_fun/$sessionId')
          .set(data)
          .then((_) => print('Session saved: $data'))
          .catchError((e) => print('Error saving session: $e'));
    } else {
      print('No authenticated user — session not saved');
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => FinalScoreScreen(
        gameTitle:        'Pattern Fun',
        level:            widget.level,
        score:            _score,
        errors:           _errors,
        maxScore:         totalRounds,
        timeSecs:         _seconds,
        userId:           widget.userId,
        nextLevelBuilder: widget.level < 3
            ? (_) => PatternFunGame(level: widget.level + 1, userId: widget.userId)
            : null,
      ),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  String _emojiFor(String id) =>
      Emotion.fromId(id)?.emoji ?? id;

  @override
  Widget build(BuildContext context) {
    final q     = _current;
    final round = _round + 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GameTopBar(
              round: round, totalRounds: totalRounds,
              timeStr: _fmt(_seconds), score: _score,
              accentGradient: AppTheme.greenGradient,
              onBack: () { _timer?.cancel(); Navigator.pop(context); },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _GradientProgressBar(
                value: round / totalRounds,
                gradient: AppTheme.greenGradient,
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ScoreChip(
                score: _score, total: totalRounds,
                gradient: AppTheme.greenGradient,
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(q.question,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 12),

            // Pattern display box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6, runSpacing: 6,
                  children: [
                    ...List.generate(q.shown.length, (i) {
                      final emoji = _emojiFor(q.shown[i]);
                      final sz = q.shownSz[i];
                      return Text(emoji, style: TextStyle(fontSize: sz));
                    }),
                    ...List.generate(q.blanks.length, (_) => Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text('?',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Choices
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: q.twoSlot
                    ? _PairGrid(
                        choices: q.choices, answered: _answered,
                        selected: _selected, blanks: q.blanks,
                        emojiFor: _emojiFor, onTap: _answer,
                      )
                    : _SingleGrid(
                        choices: q.choices, answered: _answered,
                        selected: _selected, correct: q.blanks.first,
                        emojiFor: _emojiFor, onTap: _answer,
                      ),
              ),
            ),

            if (_answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _FeedbackBanner(correct: _isCorrect(_selected ?? '')),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Shared top bar, progress bar, score chip ──────────────────────────────────

class _GameTopBar extends StatelessWidget {
  final int round, totalRounds, score;
  final String timeStr;
  final LinearGradient accentGradient;
  final VoidCallback onBack;
  const _GameTopBar({required this.round, required this.totalRounds,
      required this.timeStr, required this.score,
      required this.accentGradient, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Round $round / $totalRounds',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14,
                    color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(timeStr,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final double value;
  final LinearGradient gradient;
  const _GradientProgressBar({required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppTheme.border),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: gradient,
            boxShadow: [BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int score, total;
  final LinearGradient gradient;
  const _ScoreChip({required this.score, required this.total, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), color: Colors.white,
          boxShadow: AppTheme.cardShadow),
      child: Row(
        children: [
          Text('Level score',
              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          ShaderMask(
            shaderCallback: (b) => gradient.createShader(b),
            child: Text('$score / $total',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Single choice grid ────────────────────────────────────────────────────────

class _SingleGrid extends StatelessWidget {
  final List<String> choices;
  final bool answered;
  final String? selected;
  final String correct;
  final String Function(String) emojiFor;
  final ValueChanged<String> onTap;

  const _SingleGrid({required this.choices, required this.answered,
      required this.selected, required this.correct,
      required this.emojiFor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: choices.map((id) {
        final isCorrect  = id == correct;
        final isSelected = selected == id;
        return GestureDetector(
          onTap: () => onTap(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: answered && isCorrect
                  ? const LinearGradient(colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
                  : answered && isSelected
                      ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)])
                      : LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)]),
              border: Border.all(
                color: answered && isCorrect ? AppTheme.green
                    : answered && isSelected ? AppTheme.coral
                    : const Color(0xFFEEEEEE),
                width: 1.5,
              ),
              boxShadow: [BoxShadow(
                  color: const Color(0xFF5B4FCF).withOpacity(0.06),
                  blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emojiFor(id), style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                Text(Emotion.fromId(id)?.name ?? id,
                    style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: answered && (isCorrect || isSelected)
                            ? Colors.white
                            : AppTheme.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Pair grid ─────────────────────────────────────────────────────────────────

class _PairGrid extends StatelessWidget {
  final List<String> choices;
  final bool answered;
  final String? selected;
  final List<String> blanks;
  final String Function(String) emojiFor;
  final ValueChanged<String> onTap;

  const _PairGrid({required this.choices, required this.answered,
      required this.selected, required this.blanks,
      required this.emojiFor, required this.onTap});

  bool _isCorrect(String c) {
    final parts = c.split('|');
    return parts.length == blanks.length &&
        List.generate(blanks.length, (i) => parts[i] == blanks[i]).every((x) => x);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: choices.map((pair) {
        final parts      = pair.split('|');
        final isCorrect  = _isCorrect(pair);
        final isSelected = selected == pair;
        return GestureDetector(
          onTap: () => onTap(pair),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: answered && isCorrect
                  ? const LinearGradient(colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
                  : answered && isSelected
                      ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)])
                      : LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)]),
              border: Border.all(
                color: answered && isCorrect ? AppTheme.green
                    : answered && isSelected ? AppTheme.coral
                    : const Color(0xFFEEEEEE),
                width: 1.5,
              ),
              boxShadow: [BoxShadow(
                  color: const Color(0xFF5B4FCF).withOpacity(0.06),
                  blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: parts.map((id) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(emojiFor(id), style: const TextStyle(fontSize: 24)),
                  )).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  parts.map((id) => Emotion.fromId(id)?.name ?? id).join(' + '),
                  style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: answered && (isCorrect || isSelected)
                          ? Colors.white.withOpacity(0.85)
                          : AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool correct;
  const _FeedbackBanner({required this.correct});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: correct
            ? const LinearGradient(colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
            : const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)]),
        boxShadow: [BoxShadow(
          color: (correct ? AppTheme.green : AppTheme.coral).withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      child: Text(
        correct ? "You're doing great! 🌟" : "Try again! 🔄",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
