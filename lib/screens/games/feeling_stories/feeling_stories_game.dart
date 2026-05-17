import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/emotion.dart';
import '../../../services/audio_service.dart';
import '../../../theme/app_theme.dart';
import '../../final_score_screen.dart';

// ── Scene data ────────────────────────────────────────────────────────────────

class _Scene {
  final String character;
  final String situation;
  final String emoji;
  final Color  sceneBg;
  final String correctId;
  final List<String> choiceIds;

  const _Scene({
    required this.character,
    required this.situation,
    required this.emoji,
    required this.sceneBg,
    required this.correctId,
    required this.choiceIds,
  });
}

const _easy = <_Scene>[
  _Scene(character:'Mia',   situation:'It is Mia\'s birthday. Everyone sings and gives her a big cake.',      emoji:'🎂', sceneBg:Color(0xFFFFF8E1), correctId:'happy',     choiceIds:['happy','sad','angry','fear']),
  _Scene(character:'Tom',   situation:'Tom cannot find his favourite teddy bear. He looked everywhere.',       emoji:'🧸', sceneBg:Color(0xFFE3F2FD), correctId:'sad',       choiceIds:['happy','sad','surprised','angry']),
  _Scene(character:'Lily',  situation:'Lily gets a shiny new bicycle as a gift from her parents!',            emoji:'🎁', sceneBg:Color(0xFFF3E5F5), correctId:'happy',     choiceIds:['happy','sad','fear','surprised']),
  _Scene(character:'Ben',   situation:'Ben is playing outside with his friends on a sunny day.',              emoji:'⛅', sceneBg:Color(0xFFE8F5E9), correctId:'happy',     choiceIds:['happy','bored','sad','angry']),
  _Scene(character:'Sara',  situation:'Sara sees a huge spider right next to her hand on the wall!',          emoji:'🕷️', sceneBg:Color(0xFFFCE4EC), correctId:'fear',      choiceIds:['angry','happy','fear','surprised']),
  _Scene(character:'Jake',  situation:'Jake spilled his glass of juice all over his homework.',               emoji:'🥤', sceneBg:Color(0xFFFFF3E0), correctId:'sad',       choiceIds:['sad','happy','angry','surprised']),
  _Scene(character:'Amy',   situation:'Amy\'s brother broke her favourite crayon on purpose.',                emoji:'🖍️', sceneBg:Color(0xFFFCE4EC), correctId:'angry',     choiceIds:['sad','angry','happy','surprised']),
  _Scene(character:'Leo',   situation:'Leo\'s friends jumped out and yelled SURPRISE! He had no idea.',       emoji:'🎉', sceneBg:Color(0xFFF3E5F5), correctId:'surprised', choiceIds:['happy','surprised','sad','fear']),
  _Scene(character:'Nora',  situation:'Nora\'s puppy runs to greet her every day when she comes home.',       emoji:'🐶', sceneBg:Color(0xFFE8F5E9), correctId:'happy',     choiceIds:['happy','sad','fear','angry']),
  _Scene(character:'Max',   situation:'Max\'s team won the football game with a last-minute goal!',           emoji:'⚽', sceneBg:Color(0xFFE3F2FD), correctId:'happy',     choiceIds:['happy','sad','surprised','fear']),
  _Scene(character:'Zoe',   situation:'Zoe dropped her ice cream on the pavement just after buying it.',      emoji:'🍦', sceneBg:Color(0xFFFFF8E1), correctId:'sad',       choiceIds:['sad','happy','angry','disgust']),
  _Scene(character:'Finn',  situation:'A big growling dog ran up to Finn at the park.',                       emoji:'🐕', sceneBg:Color(0xFFFCE4EC), correctId:'fear',      choiceIds:['fear','angry','surprised','happy']),
];

const _medium = <_Scene>[
  _Scene(character:'Ella',  situation:'Ella studied all night but still got a bad grade on her test.',        emoji:'📝', sceneBg:Color(0xFFFFF3E0), correctId:'worried',   choiceIds:['worried','calm','happy','bored']),
  _Scene(character:'Chris', situation:'Chris and his best friend argued about which game to play.',           emoji:'🎮', sceneBg:Color(0xFFFCE4EC), correctId:'frustrated',choiceIds:['frustrated','happy','calm','tired']),
  _Scene(character:'Maya',  situation:'Maya practised for weeks but lost the spelling competition.',          emoji:'🏆', sceneBg:Color(0xFFE3F2FD), correctId:'frustrated',choiceIds:['frustrated','guilty','calm','bored']),
  _Scene(character:'Owen',  situation:'Owen forgot his homework at home and the teacher will ask for it.',    emoji:'📚', sceneBg:Color(0xFFFFF8E1), correctId:'nervous',   choiceIds:['nervous','happy','calm','guilty']),
  _Scene(character:'Iris',  situation:'Iris waited in a very long and slow queue at the supermarket.',        emoji:'🛒', sceneBg:Color(0xFFE8F5E9), correctId:'bored',     choiceIds:['bored','angry','calm','tired']),
  _Scene(character:'Dan',   situation:'Dan has three tests, two projects and a football game all this week.', emoji:'📅', sceneBg:Color(0xFFFCE4EC), correctId:'nervous',   choiceIds:['nervous','happy','calm','bored']),
  _Scene(character:'Kai',   situation:'Kai cannot figure out a tricky maths puzzle no matter how hard he tries.', emoji:'🔢', sceneBg:Color(0xFFF3E5F5), correctId:'confused', choiceIds:['confused','angry','calm','bored']),
  _Scene(character:'Leah',  situation:'Leah told a lie and now feels bad about it, even though nobody knows.',emoji:'🤫', sceneBg:Color(0xFFFFF8E1), correctId:'guilty',    choiceIds:['guilty','calm','happy','worried']),
  _Scene(character:'Sam',   situation:'Sam was not invited to a birthday party that all her friends went to.',emoji:'🎈', sceneBg:Color(0xFFE3F2FD), correctId:'sad',       choiceIds:['sad','angry','calm','worried']),
  _Scene(character:'Tara',  situation:'Tara reads quietly by the window on a calm Sunday afternoon.',         emoji:'📖', sceneBg:Color(0xFFE8F5E9), correctId:'calm',      choiceIds:['calm','happy','bored','tired']),
  _Scene(character:'Will',  situation:'Will worked hard all day and needs to go to bed early.',               emoji:'🛏️', sceneBg:Color(0xFFF3E5F5), correctId:'tired',     choiceIds:['tired','calm','bored','sad']),
  _Scene(character:'Rose',  situation:'Rose got new instructions for a game but they are very hard to follow.',emoji:'📋', sceneBg:Color(0xFFFCE4EC), correctId:'confused', choiceIds:['confused','angry','calm','worried']),
];

const _hard = <_Scene>[
  _Scene(character:'Jamie', situation:'Jamie\'s best friend got the limited-edition toy Jamie had been saving for.',emoji:'🪀', sceneBg:Color(0xFFFFF8E1), correctId:'jealous',      choiceIds:['jealous','happy','sad','guilty']),
  _Scene(character:'Alex',  situation:'Alex sits alone at the cafeteria while all classmates eat together at another table.', emoji:'🍱', sceneBg:Color(0xFFE3F2FD), correctId:'lonely',  choiceIds:['lonely','sad','angry','jealous']),
  _Scene(character:'Kim',   situation:'Kim accidentally broke Mum\'s favourite vase and is hiding from her.',emoji:'🏺', sceneBg:Color(0xFFFCE4EC), correctId:'ashamed',      choiceIds:['ashamed','afraid','guilty','sad']),
  _Scene(character:'Pat',   situation:'Pat is blamed for something that happened, but Pat did not do it.',   emoji:'🕵️', sceneBg:Color(0xFFFFF3E0), correctId:'suspicious',   choiceIds:['suspicious','angry','ashamed','lonely']),
  _Scene(character:'Quinn', situation:'Quinn expected an A on the project but received a B-.',               emoji:'📊', sceneBg:Color(0xFFE8F5E9), correctId:'disappointed', choiceIds:['disappointed','angry','sad','ashamed']),
  _Scene(character:'Blake', situation:'Blake\'s cousin got more candy in their bag than Blake did.',         emoji:'🍬', sceneBg:Color(0xFFF3E5F5), correctId:'jealous',      choiceIds:['jealous','angry','sad','disappointed']),
  _Scene(character:'Drew',  situation:'Drew overheard the teacher telling another student their grade first.',emoji:'👂', sceneBg:Color(0xFFFCE4EC), correctId:'suspicious',   choiceIds:['suspicious','jealous','ashamed','angry']),
  _Scene(character:'Avery', situation:'Avery cheated on a test and now everyone is congratulating them.',    emoji:'😬', sceneBg:Color(0xFFFFF8E1), correctId:'ashamed',      choiceIds:['ashamed','happy','guilty','lonely']),
  _Scene(character:'River', situation:'River\'s best friend moved to another city. They only talk online now.',emoji:'📱', sceneBg:Color(0xFFE3F2FD), correctId:'lonely',  choiceIds:['lonely','sad','disappointed','angry']),
  _Scene(character:'Sage',  situation:'Sage was put in the advanced class but expected to stay with their friends.',emoji:'🏫', sceneBg:Color(0xFFE8F5E9), correctId:'disappointed',choiceIds:['disappointed','angry','lonely','ashamed']),
  _Scene(character:'Wren',  situation:'Wren was secretly told about a surprise for someone, but accidentally told them.', emoji:'😯', sceneBg:Color(0xFFF3E5F5), correctId:'guilty', choiceIds:['guilty','ashamed','sad','disappointed']),
  _Scene(character:'Robin', situation:'Robin heard a rumour that their friends have been saying mean things.',emoji:'💬', sceneBg:Color(0xFFFCE4EC), correctId:'suspicious',   choiceIds:['suspicious','angry','lonely','sad']),
];

// ── Game screen ───────────────────────────────────────────────────────────────

class FeelingStoriesGame extends StatefulWidget {
  final int level;
  final String userId;
  const FeelingStoriesGame({super.key, required this.level, required this.userId});

  @override
  State<FeelingStoriesGame> createState() => _FeelingStoriesGameState();
}

class _FeelingStoriesGameState extends State<FeelingStoriesGame> {
  static const int totalRounds = 12;

  late final List<_Scene> _scenes;
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
    final pool = widget.level == 1 ? _easy
                : widget.level == 2 ? _medium : _hard;
    _scenes = [...pool]..shuffle();
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _seconds++); });
  }

  _Scene get _current => _scenes[_round];

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    return '$m:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _answer(String id) async {
    if (_answered) return;
    final correct = id == _current.correctId;
    setState(() { _selected = id; _answered = true; if (correct) {
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
        'gameId':      'feeling_stories',
      };
      FirebaseDatabase.instance
          .ref('users/${user.uid}/sessions/feeling_stories/$sessionId')
          .set(data)
          .then((_) => print('Session saved: $data'))
          .catchError((e) => print('Error saving session: $e'));
    } else {
      print('No authenticated user — session not saved');
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => FinalScoreScreen(
        gameTitle:        'Feeling Stories',
        level:            widget.level,
        score:            _score,
        errors:           _errors,
        maxScore:         totalRounds,
        timeSecs:         _seconds,
        userId:           widget.userId,
        nextLevelBuilder: widget.level < 3
            ? (_) => FeelingStoriesGame(level: widget.level + 1, userId: widget.userId)
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

  @override
  Widget build(BuildContext context) {
    final scene = _current;
    final round = _round + 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _GameTopBar(
              round: round,
              totalRounds: totalRounds,
              timeStr: _fmt(_seconds),
              score: _score,
              accentGradient: AppTheme.amberGradient,
              onBack: () { _timer?.cancel(); Navigator.pop(context); },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _GradientProgressBar(
                value: round / totalRounds,
                gradient: AppTheme.amberGradient,
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ScoreChip(
                score: _score,
                total: totalRounds,
                gradient: AppTheme.amberGradient,
              ),
            ),
            const SizedBox(height: 12),

            // ── Scene card ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 155,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: scene.sceneBg.withOpacity(0.9),
                        border: Border.all(
                          color: const Color(0xFFFFB347).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(scene.emoji,
                                style: const TextStyle(fontSize: 72)),
                          ),
                          Positioned(
                            left: 0, right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    Colors.black.withOpacity(0.55),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(20)),
                              ),
                              child: Text(
                                scene.situation,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('How does ${scene.character} feel?',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: scene.choiceIds.map((id) {
                    final e = Emotion.fromId(id) ?? Emotion.all.first;
                    final isSelected = _selected == id;
                    final isCorrect  = id == scene.correctId;
                    return GestureDetector(
                      onTap: () => _answer(id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: _answered && isCorrect
                              ? const LinearGradient(
                                  colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)])
                              : _answered && isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)])
                                  : LinearGradient(colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.95)
                                    ]),
                          border: Border.all(
                            color: _answered && isCorrect
                                ? AppTheme.green
                                : _answered && isSelected
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
                            Text(e.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(e.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: _answered && (isCorrect || isSelected)
                                          ? Colors.white
                                          : AppTheme.textPrimary),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (_answered && isCorrect) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle,
                                  size: 13, color: Colors.white),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            if (_answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _FeedbackBanner(correct: _selected == scene.correctId),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets (re-use from mood match game) ──────────────────────────────

class _GameTopBar extends StatelessWidget {
  final int round;
  final int totalRounds;
  final String timeStr;
  final int score;
  final LinearGradient accentGradient;
  final VoidCallback onBack;

  const _GameTopBar({
    required this.round, required this.totalRounds,
    required this.timeStr, required this.score,
    required this.accentGradient, required this.onBack,
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

class _ScoreChip extends StatelessWidget {
  final int score;
  final int total;
  final LinearGradient gradient;
  const _ScoreChip({required this.score, required this.total, required this.gradient});

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
            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
