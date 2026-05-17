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

// ── Photo entry ───────────────────────────────────────────────────────────────

class _PhotoEntry {
  final String assetPath;
  final String emotionId;
  const _PhotoEntry(this.assetPath, this.emotionId);
}

// ── Photo lists per level ─────────────────────────────────────────────────────

const _levelPhotos = <int, List<_PhotoEntry>>{
  1: [
    _PhotoEntry('assets/images/Mood Match/easy/happy1.png',     'happy'),
    _PhotoEntry('assets/images/Mood Match/easy/happy2.png',     'happy'),
    _PhotoEntry('assets/images/Mood Match/easy/sad1.png',       'sad'),
    _PhotoEntry('assets/images/Mood Match/easy/sad2.png',       'sad'),
    _PhotoEntry('assets/images/Mood Match/easy/angry1.jpeg',    'angry'),
    _PhotoEntry('assets/images/Mood Match/easy/angry2.jpg',     'angry'),
    _PhotoEntry('assets/images/Mood Match/easy/scared1.png',    'fear'),
    _PhotoEntry('assets/images/Mood Match/easy/scared2.png',    'fear'),
    _PhotoEntry('assets/images/Mood Match/easy/disgust1.png',   'disgust'),
    _PhotoEntry('assets/images/Mood Match/easy/disgust2.png',   'disgust'),
    _PhotoEntry('assets/images/Mood Match/easy/surprised1.png', 'surprised'),
    _PhotoEntry('assets/images/Mood Match/easy/surprised2.png', 'surprised'),
  ],
  2: [
    _PhotoEntry('assets/images/Mood Match/medium/bored1.png',      'bored'),
    _PhotoEntry('assets/images/Mood Match/medium/bored 2.png',     'bored'),
    _PhotoEntry('assets/images/Mood Match/medium/confused1.png',   'confused'),
    _PhotoEntry('assets/images/Mood Match/medium/confused2.png',   'confused'),
    _PhotoEntry('assets/images/Mood Match/medium/calm1.png',       'calm'),
    _PhotoEntry('assets/images/Mood Match/medium/calm2.png',       'calm'),
    _PhotoEntry('assets/images/Mood Match/medium/nervous1.png',    'nervous'),
    _PhotoEntry('assets/images/Mood Match/medium/nervous2.png',    'nervous'),
    _PhotoEntry('assets/images/Mood Match/medium/frustrated1.png', 'frustrated'),
    _PhotoEntry('assets/images/Mood Match/medium/frustrated2.png', 'frustrated'),
    _PhotoEntry('assets/images/Mood Match/medium/tired1.png',      'tired'),
    _PhotoEntry('assets/images/Mood Match/medium/tired2.png',      'tired'),
  ],
  3: [
    _PhotoEntry('assets/images/Mood Match/hard/ashamed1.png',      'ashamed'),
    _PhotoEntry('assets/images/Mood Match/hard/ashamed2.png',      'ashamed'),
    _PhotoEntry('assets/images/Mood Match/hard/disappointed1.png', 'disappointed'),
    _PhotoEntry('assets/images/Mood Match/hard/disappointed2.png', 'disappointed'),
    _PhotoEntry('assets/images/Mood Match/hard/lonely1.png',       'lonely'),
    _PhotoEntry('assets/images/Mood Match/hard/lonely2.png',       'lonely'),
    _PhotoEntry('assets/images/Mood Match/hard/guilty1.png',       'guilty'),
    _PhotoEntry('assets/images/Mood Match/hard/guilty2.png',       'guilty'),
    _PhotoEntry('assets/images/Mood Match/hard/worried1.png',      'worried'),
    _PhotoEntry('assets/images/Mood Match/hard/worried2.png',      'worried'),
    _PhotoEntry('assets/images/Mood Match/hard/jealous1.jpg',      'jealous'),
    _PhotoEntry('assets/images/Mood Match/hard/jealous2.png',      'jealous'),
  ],
};

// ── Game ──────────────────────────────────────────────────────────────────────

class MoodMatchGame extends StatefulWidget {
  final int level;
  final String userId;
  const MoodMatchGame({super.key, required this.level, required this.userId});

  @override
  State<MoodMatchGame> createState() => _MoodMatchGameState();
}

class _MoodMatchGameState extends State<MoodMatchGame>
    with TickerProviderStateMixin {
  static const int totalRounds = 12;

  late final List<_Round> _rounds;
  int _roundIndex = 0;
  int _score  = 0;
  int _errors = 0;
  String? _selected;
  bool _answered = false;

  int _seconds = 0;
  Timer? _timer;

  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;
  late final AnimationController _bounceCtrl;
  late final Animation<double>   _bounceAnim;

  final _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _rounds = _buildRounds();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bounceAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));

    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _seconds++); });
  }

  List<_Round> _buildRounds() {
    final rng    = Random();
    final photos = [..._levelPhotos[widget.level]!]..shuffle(rng);
    final emotions = Emotion.forGameLevel(widget.level);

    return photos.map((photo) {
      final correct = Emotion.fromId(photo.emotionId) ?? emotions.first;
      final pool = [...emotions]
        ..removeWhere((e) => e.id == correct.id)
        ..shuffle(rng);
      final choices = [correct, ...pool.take(3)]..shuffle(rng);
      return _Round(assetPath: photo.assetPath, correct: correct, choices: choices);
    }).toList();
  }

  _Round get _current => _rounds[_roundIndex];

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    return '$m:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _answer(String id) async {
    if (_answered) return;
    final correct = id == _current.correct.id;
    setState(() {
      _selected = id;
      _answered = true;
      if (correct) { _score++; } else { _errors++; }
    });

    if (correct) {
      _bounceCtrl.forward(from: 0);
      await _audio.playFeedback(correct: true);
    } else {
      _shakeCtrl.forward(from: 0);
      await _audio.playFeedback(correct: false);
    }
    await Future.delayed(const Duration(milliseconds: 1000));

    if (_roundIndex < totalRounds - 1) {
      setState(() { _roundIndex++; _selected = null; _answered = false; });
      _bounceCtrl.reset();
    } else {
      _finish();
    }
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
        'gameId':      'mood_match',
      };
      FirebaseDatabase.instance
          .ref('users/${user.uid}/sessions/mood_match/$sessionId')
          .set(data)
          .then((_) => print('Session saved: $data'))
          .catchError((e) => print('Error saving session: $e'));
    } else {
      print('No authenticated user — session not saved');
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => FinalScoreScreen(
        gameTitle:        'Mood Match',
        level:            widget.level,
        score:            _score,
        errors:           _errors,
        maxScore:         totalRounds,
        timeSecs:         _seconds,
        userId:           widget.userId,
        nextLevelBuilder: widget.level < 3
            ? (_) => MoodMatchGame(level: widget.level + 1, userId: widget.userId)
            : null,
      ),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    _bounceCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round    = _roundIndex + 1;
    final progress = round / totalRounds;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _GameTopBar(
              round: round,
              totalRounds: totalRounds,
              timeStr: _fmt(_seconds),
              score: _score,
              accentGradient: AppTheme.coralGradient,
              onBack: () { _timer?.cancel(); Navigator.pop(context); },
            ),

            // ── Progress bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _GradientProgressBar(
                value: progress,
                gradient: AppTheme.coralGradient,
              ),
            ),
            const SizedBox(height: 12),

            // ── Score chip ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ScoreChip(
                score: _score,
                total: totalRounds,
                gradient: AppTheme.coralGradient,
              ),
            ),
            const SizedBox(height: 14),

            // ── Photo card ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (_, child) => Transform.scale(
                  scale: 1.0 + sin(_bounceAnim.value * pi) * 0.04,
                  child: child,
                ),
                child: _PhotoCard(
                  assetPath: _current.assetPath,
                  accentColor: const Color(0xFFFF6B6B),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('How does this child feel?',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 12),

            // ── Choice grid ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),

            // ── Feedback banner ──────────────────────────────────────────
            if (_answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _FeedbackBanner(correct: _selected == _current.correct.id),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Shared game top bar ───────────────────────────────────────────────────────

class _GameTopBar extends StatelessWidget {
  final int round;
  final int totalRounds;
  final String timeStr;
  final int score;
  final LinearGradient accentGradient;
  final VoidCallback onBack;

  const _GameTopBar({
    required this.round,
    required this.totalRounds,
    required this.timeStr,
    required this.score,
    required this.accentGradient,
    required this.onBack,
  });

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
                shape: BoxShape.circle,
                color: Colors.white,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
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

// ── Gradient progress bar ─────────────────────────────────────────────────────

class _GradientProgressBar extends StatelessWidget {
  final double value;
  final LinearGradient gradient;

  const _GradientProgressBar({required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.border,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score chip ────────────────────────────────────────────────────────────────

class _ScoreChip extends StatelessWidget {
  final int score;
  final int total;
  final LinearGradient gradient;

  const _ScoreChip({
    required this.score,
    required this.total,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Text('Level score',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          ShaderMask(
            shaderCallback: (b) => gradient.createShader(b),
            child: Text('$score / $total',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Photo card ────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final String assetPath;
  final Color accentColor;
  const _PhotoCard({required this.assetPath, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              assetPath,
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: double.infinity,
                height: 190,
                color: const Color(0xFFEEEEEE),
                child: const Icon(Icons.image_not_supported_outlined,
                    size: 48, color: Color(0xFFBBBBBB)),
              ),
            ),
            // Corner brackets
            ..._cornerBrackets(accentColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _cornerBrackets(Color c) {
    const t = 3.0; const sz = 24.0; const pad = 10.0;
    Widget b(bool left, bool top) => Positioned(
      top:    top  ? pad : null,
      bottom: !top ? pad : null,
      left:   left ? pad : null,
      right:  !left ? pad : null,
      child: SizedBox(
        width: sz, height: sz,
        child: CustomPaint(
          painter: _CornerPainter(left: left, top: top, color: c, thickness: t),
        ),
      ),
    );
    return [b(true, true), b(false, true), b(true, false), b(false, false)];
  }
}

class _CornerPainter extends CustomPainter {
  final bool  left, top;
  final Color color;
  final double thickness;
  const _CornerPainter({
    required this.left, required this.top,
    required this.color, required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x  = left ? 0.0 : size.width;
    final y  = top  ? 0.0 : size.height;
    final dx = left ? size.width  : -size.width;
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
    Widget chip = GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: answered && isCorrect
              ? const LinearGradient(
                  colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
              : answered && isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)])
                  : LinearGradient(colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95)
                    ]),
          border: Border.all(
            color: answered && isCorrect
                ? AppTheme.green
                : answered && isSelected
                    ? AppTheme.coral
                    : const Color(0xFFEEEEEE),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B4FCF).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                emotion.name,
                style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: answered && (isCorrect || isSelected)
                      ? Colors.white
                      : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (answered && isCorrect) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 14, color: Colors.white),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: correct
            ? const LinearGradient(
                colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
            : const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)]),
        boxShadow: [
          BoxShadow(
            color: (correct ? AppTheme.green : AppTheme.coral).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        correct ? "You're doing great! 🌟" : "Try again! 🔄",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
        ),
      ),
    );
  }
}

class _Round {
  final String assetPath;
  final Emotion correct;
  final List<Emotion> choices;
  _Round({required this.assetPath, required this.correct, required this.choices});
}
