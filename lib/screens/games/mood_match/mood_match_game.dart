import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/emotion.dart';
import '../../../models/game_result.dart';
import '../../../services/audio_service.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';
import '../../final_score_screen.dart';

class MoodMatchGame extends StatefulWidget {
  final int level;      // 1 = easy, 2 = medium, 3 = hard
  final String userId;
  const MoodMatchGame({super.key, required this.level, required this.userId});

  @override
  State<MoodMatchGame> createState() => _MoodMatchGameState();
}

class _MoodMatchGameState extends State<MoodMatchGame>
    with SingleTickerProviderStateMixin {
  static const int totalRounds = 12;

  late final List<_Round> _rounds;
  int _roundIndex = 0;
  int _score  = 0;
  int _errors = 0;
  String? _selected;
  bool _answered = false;

  // Stopwatch
  int _seconds = 0;
  Timer? _timer;

  // Shake animation for wrong answer
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  final _audio = AudioService();
  final _gs    = GameService();

  @override
  void initState() {
    super.initState();
    _rounds = _buildRounds();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _seconds++); });
  }

  List<_Round> _buildRounds() {
    final emotions = Emotion.forGameLevel(widget.level);
    final rng = Random();
    final rounds = <_Round>[];

    for (int i = 0; i < totalRounds; i++) {
      final correct = emotions[i % emotions.length];
      final pool = [...emotions]..remove(correct)..shuffle(rng);
      final choices = [correct, ...pool.take(3)]..shuffle(rng);
      rounds.add(_Round(correct: correct, choices: choices));
    }
    rounds.shuffle(rng);
    return rounds;
  }

  _Round get _current => _rounds[_roundIndex];

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  Future<void> _answer(String id) async {
    if (_answered) return;
    final correct = id == _current.correct.id;
    setState(() {
      _selected = id;
      _answered = true;
      if (correct) _score++; else _errors++;
    });

    if (correct) {
      await _audio.playFeedback(correct: true);
    } else {
      _shakeCtrl.forward(from: 0);
      await _audio.playFeedback(correct: false);
    }
    await Future.delayed(const Duration(milliseconds: 1000));

    if (_roundIndex < totalRounds - 1) {
      setState(() { _roundIndex++; _selected = null; _answered = false; });
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    final result = GameResult(
      gameId:      'mood_match',
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
        gameTitle: 'Mood Match',
        level:     widget.level,
        score:     _score,
        maxScore:  totalRounds,
        timeSecs:  _seconds,
        userId:    widget.userId,
      ),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round    = _roundIndex + 1;
    final progress = round / totalRounds;

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
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation(AppTheme.brandPurple),
              ),
            ),
            const SizedBox(height: 12),

            // Score bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.brandLightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('Level score',
                      style: TextStyle(fontSize: 13, color: AppTheme.brandPurple)),
                  const Spacer(),
                  Text('$_score / $totalRounds',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppTheme.brandPurple)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Face placeholder (replaces emoji)
            _FaceCard(emotion: _current.correct),
            const SizedBox(height: 12),

            const Text('How does this child feel?',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 14),

            // 2×2 choice grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: _current.choices.map((e) {
                  return _ChoiceChip(
                    emotion: e,
                    answered: _answered,
                    isCorrect: e.id == _current.correct.id,
                    isSelected: _selected == e.id,
                    shakeAnim: (e.id == _selected && _selected != _current.correct.id)
                        ? _shakeAnim : null,
                    onTap: () => _answer(e.id),
                  );
                }).toList(),
              ),
            ),

            // Feedback banner
            if (_answered) _FeedbackBanner(correct: _selected == _current.correct.id),
          ],
        ),
      ),
    );
  }
}

// ── Face card (photo placeholder) ────────────────────────────────────────────
// Replace Image.asset() with real AI-generated child photos

class _FaceCard extends StatelessWidget {
  final Emotion emotion;
  const _FaceCard({required this.emotion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: _cardBg(emotion.id),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.brandPurple.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Stack(
        children: [
          // Corner brackets
          ..._corners(AppTheme.brandPurple),

          // Face illustration
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(painter: _FacePainter(emotion.id)),
            ),
          ),

          // Emotion label badge (top-left — shows therapist where to place real photo)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.brandPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                emotion.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.brandPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _cardBg(String id) {
    const map = {
      'happy':       Color(0xFFFFF9C4),
      'sad':         Color(0xFFBBDEFB),
      'angry':       Color(0xFFFFCDD2),
      'fear':        Color(0xFFE1BEE7),
      'surprised':   Color(0xFFB3E5FC),
      'disgust':     Color(0xFFC8E6C9),
      'frustrated':  Color(0xFFFFCCBC),
      'worried':     Color(0xFFE3F2FD),
      'calm':        Color(0xFFE8F5E9),
      'bored':       Color(0xFFF5F5F5),
      'tired':       Color(0xFFECEFF1),
      'confused':    Color(0xFFFFF3E0),
      'guilty':      Color(0xFFEDE7F6),
      'nervous':     Color(0xFFFCE4EC),
    };
    return map[id] ?? const Color(0xFFEEEEEE);
  }

  static List<Widget> _corners(Color c) {
    const t = 2.5; const sz = 18.0; const pad = 10.0;
    Widget b(bool left, bool top) => Positioned(
      top:    top  ? pad : null,
      bottom: !top ? pad : null,
      left:   left ? pad : null,
      right:  !left? pad : null,
      child: SizedBox(width: sz, height: sz,
          child: CustomPaint(painter: _CornerPainter(left, top, c, t))),
    );
    return [b(true,true), b(false,true), b(true,false), b(false,false)];
  }
}

// ── Face CustomPainter ────────────────────────────────────────────────────────

class _FacePainter extends CustomPainter {
  final String emotionId;
  const _FacePainter(this.emotionId);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;

    // Head
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFFFFC87C),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final eyePaint = Paint()..color = const Color(0xFF333333);
    final eyeY     = cy - size.height * 0.08;
    final eyeX     = size.width  * 0.14;
    final eyeR     = _eyesWide ? size.width * 0.065 : size.width * 0.047;

    // Eyes
    if (emotionId == 'tired') {
      // Half-closed: draw arcs
      final p = Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      for (final dx in [-eyeX, eyeX]) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx + dx, eyeY), radius: eyeR),
          0, pi, false, p,
        );
      }
    } else {
      canvas.drawCircle(Offset(cx - eyeX, eyeY), eyeR, eyePaint);
      canvas.drawCircle(Offset(cx + eyeX, eyeY), eyeR, eyePaint);
      // Pupils
      canvas.drawCircle(Offset(cx - eyeX + 1, eyeY + 1), eyeR * 0.45,
          Paint()..color = Colors.white.withValues(alpha: 0.6));
      canvas.drawCircle(Offset(cx + eyeX + 1, eyeY + 1), eyeR * 0.45,
          Paint()..color = Colors.white.withValues(alpha: 0.6));
    }

    // Eyebrows
    _drawEyebrows(canvas, size, cx, eyeY, eyeX);

    // Mouth
    _drawMouth(canvas, size, cx, cy);
  }

  void _drawEyebrows(Canvas c, Size s, double cx, double eyeY, double eyeX) {
    final p = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browY = eyeY - s.height * 0.115;
    final w     = s.width * 0.07;

    double tiltL = 0; // positive = inner end higher (sad), negative = inner end lower (angry)
    double raise = 0; // move both brows up (surprised)

    switch (emotionId) {
      case 'angry':
      case 'frustrated':
      case 'jealous':
      case 'suspicious':
        tiltL = -1.0;
      case 'sad':
      case 'worried':
      case 'nervous':
      case 'lonely':
      case 'guilty':
      case 'ashamed':
        tiltL = 1.0;
      case 'surprised':
      case 'fear':
        raise = s.height * 0.04;
    }

    final tiltDy = tiltL * s.height * 0.028;
    final by = browY - raise;

    // Left brow: from outer→inner
    c.drawLine(
      Offset(cx - eyeX - w, by + tiltDy),
      Offset(cx - eyeX + w, by - tiltDy),
      p,
    );
    // Right brow: inner→outer
    c.drawLine(
      Offset(cx + eyeX - w, by - tiltDy),
      Offset(cx + eyeX + w, by + tiltDy),
      p,
    );
  }

  void _drawMouth(Canvas c, Size s, double cx, double cy) {
    final mouthY = cy + s.height * 0.13;
    final mouthW = s.width * 0.16;

    final p = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (emotionId == 'surprised' || emotionId == 'fear') {
      // Open oval mouth
      c.drawOval(
        Rect.fromCenter(
          center: Offset(cx, mouthY + s.height * 0.02),
          width:  mouthW * 0.9,
          height: mouthW * 0.7,
        ),
        Paint()..color = const Color(0xFF555555),
      );
      return;
    }

    final curve = _mouthCurve * s.height * 0.07;
    final path  = Path()
      ..moveTo(cx - mouthW, mouthY)
      ..quadraticBezierTo(cx, mouthY + curve, cx + mouthW, mouthY);
    c.drawPath(path, p);

    if (emotionId == 'happy') {
      // Dimple lines
      final dp = Paint()
        ..color = const Color(0xFF555555).withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      c.drawLine(
        Offset(cx - mouthW - s.width * 0.02, mouthY - s.height * 0.01),
        Offset(cx - mouthW,                  mouthY + s.height * 0.025),
        dp,
      );
      c.drawLine(
        Offset(cx + mouthW + s.width * 0.02, mouthY - s.height * 0.01),
        Offset(cx + mouthW,                  mouthY + s.height * 0.025),
        dp,
      );
    }
  }

  double get _mouthCurve {
    switch (emotionId) {
      case 'happy':                                       return  1.0;
      case 'sad':
      case 'lonely':
      case 'disappointed': return -1.0;
      case 'angry':
      case 'frustrated':
      case 'jealous':      return -0.7;
      case 'worried':
      case 'nervous':
      case 'guilty':
      case 'ashamed':      return -0.5;
      case 'calm':         return  0.3;
      case 'bored':        return  0.05;
      case 'suspicious':   return -0.3;
      default:             return  0.1;
    }
  }

  bool get _eyesWide {
    return emotionId == 'surprised' || emotionId == 'fear';
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.emotionId != emotionId;
}

// ── Corner bracket painter ────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final bool left;
  final bool top;
  final Color color;
  final double thickness;

  const _CornerPainter(this.left, this.top, this.color, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final x = left ? 0.0 : size.width;
    final y = top  ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top  ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Choice chip ───────────────────────────────────────────────────────────────

class _ChoiceChip extends StatelessWidget {
  final Emotion emotion;
  final bool answered;
  final bool isCorrect;
  final bool isSelected;
  final Animation<double>? shakeAnim;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.emotion,
    required this.answered,
    required this.isCorrect,
    required this.isSelected,
    required this.shakeAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg     = Colors.white;
    Color border = const Color(0xFFEEEEEE);

    if (answered) {
      if (isCorrect) {
        bg     = AppTheme.greenLight;
        border = AppTheme.green;
      } else if (isSelected) {
        bg     = AppTheme.coralLight;
        border = AppTheme.coral;
      }
    }

    Widget chip = GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                emotion.name,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (answered && isCorrect) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 14, color: AppTheme.green),
            ],
          ],
        ),
      ),
    );

    if (shakeAnim != null) {
      return AnimatedBuilder(
        animation: shakeAnim!,
        builder: (_, child) => Transform.translate(
          offset: Offset(sin(shakeAnim!.value * pi * 6) * 6, 0),
          child: child,
        ),
        child: chip,
      );
    }
    return chip;
  }
}

// ── Feedback banner ───────────────────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  final bool correct;
  const _FeedbackBanner({required this.correct});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
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
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: correct ? const Color(0xFF1A7A50) : AppTheme.coral,
        ),
      ),
    );
  }
}

class _Round {
  final Emotion correct;
  final List<Emotion> choices;
  _Round({required this.correct, required this.choices});
}
