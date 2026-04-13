import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/emotion.dart';
import '../../../models/game_result.dart';
import '../../../services/audio_service.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';
import '../../final_score_screen.dart';

// ── Pattern question model ────────────────────────────────────────────────────

class _PQ {
  final List<String>  shown;    // emoji strings already shown
  final List<double>  shownSz;  // sizes for size-variation levels
  final List<String>  blanks;   // emoji string(s) that are the answer(s)
  final List<String>  choices;  // choice emoji strings
  final bool          twoSlot;  // hard level missing pair
  final String        question;

  _PQ({
    required this.shown,
    required this.shownSz,
    required this.blanks,
    required this.choices,
    required this.twoSlot,
    required this.question,
  });
}

List<_PQ> _buildQuestions(int level, Random rng) {
  // Pool: mix of emotion emojis + neutral ones
  final eIds  = Emotion.forGameLevel(level).map((e) => e.id).toList();

  _PQ makeAB(String a, String b) {
    // Pattern: a b a b  → answer b
    final shown = [a, b, a, b, a];
    final ans   = b;
    final others = eIds.where((x) => x != a && x != b).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(
      shown: shown, shownSz: List.filled(shown.length, 28),
      blanks: [ans], choices: choices, twoSlot: false,
      question: 'What comes next?',
    );
  }

  _PQ makeABC(String a, String b, String c) {
    final shown = [a, b, c, a, b, c, a, b];
    final ans   = c;
    final others = eIds.where((x) => x != a && x != b && x != c).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(
      shown: shown, shownSz: List.filled(shown.length, 26),
      blanks: [ans], choices: choices, twoSlot: false,
      question: 'What comes next?',
    );
  }

  _PQ makeSize(String a, String b) {
    // BIG a  small a  small a  BIG b  small b  small b  BIG?
    final shown  = [a, a, a, b, b, b, a, a, a, b, b, b];
    final sizes  = [36.0, 22.0, 22.0, 36.0, 22.0, 22.0, 36.0, 22.0, 22.0, 36.0, 22.0, 22.0];
    final ans = a;
    final others = eIds.where((x) => x != a && x != b).toList()..shuffle(rng);
    final choices = [ans, ...others.take(3)]..shuffle(rng);
    return _PQ(
      shown: shown, shownSz: sizes,
      blanks: [ans], choices: choices, twoSlot: false,
      question: 'What comes next?',
    );
  }

  _PQ makeAABB(String a, String b) {
    // a a b b a a b b _ _  → answer [a, a] encoded as "$a|$a"
    final shown = [a, a, b, b, a, a, b, b];
    final ans1 = a; final ans2 = a;
    // pair choices in 2x2 — represented as "id1|id2"
    final pairs = [
      '$a|$a',
      '$b|$b',
      '$a|$b',
      '$b|$a',
    ]..shuffle(rng);
    return _PQ(
      shown: shown, shownSz: List.filled(shown.length, 26),
      blanks: [ans1, ans2], choices: pairs, twoSlot: true,
      question: 'Complete the missing pair',
    );
  }

  final qs = <_PQ>[];
  final pool = [...eIds]..shuffle(rng);

  for (int i = 0; i < 12; i++) {
    final a = pool[i % pool.length];
    final b = pool[(i + 1) % pool.length];
    final c = pool[(i + 2) % pool.length];

    if (level == 1) qs.add(makeAB(a, b));
    if (level == 2) {
      if (i % 2 == 0) qs.add(makeABC(a, b, c));
      else qs.add(makeSize(a, b));
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
  final _gs    = GameService();

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
    setState(() { _selected = choice; _answered = true; if (correct) _score++; else _errors++; });
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
    final result = GameResult(
      gameId:      'pattern_fun',
      level:       widget.level,
      score:       _score,
      maxScore:    totalRounds,
      errors:      _errors,
      starsEarned: _gs.starsForScore(_score / totalRounds),
      timeTaken:   Duration(seconds: _seconds),
      completedAt: DateTime.now(),
    );
    if (widget.userId.isNotEmpty) _gs.saveResult(widget.userId, result);

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => FinalScoreScreen(
        gameTitle: 'Pattern Fun',
        level: widget.level,
        score: _score,
        maxScore: totalRounds,
        timeSecs: _seconds,
        userId: widget.userId,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () { _timer?.cancel(); Navigator.pop(context); },
        ),
        title: Text('Round $round / $totalRounds',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16,
                      color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(_fmt(_seconds),
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: round / totalRounds,
                minHeight: 5,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation(AppTheme.green),
              ),
            ),
            const SizedBox(height: 12),

            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('Level score',
                      style: TextStyle(fontSize: 13, color: AppTheme.green)),
                  const Spacer(),
                  Text('$_score / $totalRounds',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppTheme.green)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(q.question,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 12),

            // Pattern display box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...List.generate(q.shown.length, (i) {
                    final emoji = _emojiFor(q.shown[i]);
                    final sz = q.shownSz[i];
                    return Text(emoji, style: TextStyle(fontSize: sz));
                  }),
                  // Blank slot(s)
                  ...List.generate(q.blanks.length, (_) => Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.brandPurple,
                          style: BorderStyle.solid,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('?',
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.brandPurple,
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Choices
            Expanded(
              child: q.twoSlot
                  ? _PairGrid(
                      choices: q.choices,
                      answered: _answered,
                      selected: _selected,
                      blanks: q.blanks,
                      emojiFor: _emojiFor,
                      onTap: _answer,
                    )
                  : _SingleGrid(
                      choices: q.choices,
                      answered: _answered,
                      selected: _selected,
                      correct: q.blanks.first,
                      emojiFor: _emojiFor,
                      onTap: _answer,
                    ),
            ),

            if (_answered)
              _FeedbackBanner(correct: _isCorrect(_selected ?? '')),
          ],
        ),
      ),
    );
  }
}

// ── Single choice grid (4 choices) ───────────────────────────────────────────

class _SingleGrid extends StatelessWidget {
  final List<String> choices;
  final bool answered;
  final String? selected;
  final String correct;
  final String Function(String) emojiFor;
  final ValueChanged<String> onTap;

  const _SingleGrid({
    required this.choices, required this.answered, required this.selected,
    required this.correct, required this.emojiFor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: choices.map((id) {
        final isCorrect  = id == correct;
        final isSelected = selected == id;
        Color bg     = Colors.white;
        Color border = const Color(0xFFEEEEEE);
        if (answered) {
          if (isCorrect)  { bg = AppTheme.greenLight; border = AppTheme.green; }
          else if (isSelected) { bg = AppTheme.coralLight; border = AppTheme.coral; }
        }
        return GestureDetector(
          onTap: () => onTap(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emojiFor(id), style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                Text(Emotion.fromId(id)?.name ?? id,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Pair grid (AABB level) ────────────────────────────────────────────────────

class _PairGrid extends StatelessWidget {
  final List<String> choices;  // format "id1|id2"
  final bool answered;
  final String? selected;
  final List<String> blanks;
  final String Function(String) emojiFor;
  final ValueChanged<String> onTap;

  const _PairGrid({
    required this.choices, required this.answered, required this.selected,
    required this.blanks, required this.emojiFor, required this.onTap,
  });

  bool _isCorrect(String c) {
    final parts = c.split('|');
    return parts.length == blanks.length &&
        List.generate(blanks.length, (i) => parts[i] == blanks[i]).every((x) => x);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: choices.map((pair) {
        final parts      = pair.split('|');
        final isCorrect  = _isCorrect(pair);
        final isSelected = selected == pair;
        Color bg     = Colors.white;
        Color border = const Color(0xFFEEEEEE);
        if (answered) {
          if (isCorrect)  { bg = AppTheme.greenLight; border = AppTheme.green; }
          else if (isSelected) { bg = AppTheme.coralLight; border = AppTheme.coral; }
        }
        return GestureDetector(
          onTap: () => onTap(pair),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: parts.map((id) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(emojiFor(id),
                          style: const TextStyle(fontSize: 24)),
                    )
                  ).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  parts.map((id) => Emotion.fromId(id)?.name ?? id).join(' + '),
                  style: const TextStyle(
                      fontSize: 9, color: AppTheme.textSecondary),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: correct ? AppTheme.greenLight : AppTheme.coralLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: correct ? AppTheme.green : AppTheme.coral, width: 1),
      ),
      child: Text(
        correct ? "You're doing great! 🌟" : "Try again! 🔄",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold,
          color: correct ? const Color(0xFF1A7A50) : AppTheme.coral,
        ),
      ),
    );
  }
}
