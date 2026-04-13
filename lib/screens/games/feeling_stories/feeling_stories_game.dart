import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/emotion.dart';
import '../../../models/game_result.dart';
import '../../../services/audio_service.dart';
import '../../../services/game_service.dart';
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
  final _gs    = GameService();

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
    setState(() { _selected = id; _answered = true; if (correct) _score++; else _errors++; });
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
    final result = GameResult(
      gameId:      'feeling_stories',
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
        gameTitle: 'Feeling Stories',
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

  @override
  Widget build(BuildContext context) {
    final scene = _current;
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
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: round / totalRounds,
                minHeight: 5,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation(AppTheme.amber),
              ),
            ),
            const SizedBox(height: 12),

            // Score bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.amberLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('Level score',
                      style: TextStyle(fontSize: 13, color: AppTheme.amber)),
                  const Spacer(),
                  Text('$_score / $totalRounds',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppTheme.amber)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Scene card
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: scene.sceneBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(scene.emoji,
                        style: const TextStyle(fontSize: 72)),
                  ),
                  // Caption bar
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                      ),
                      child: Text(
                        scene.situation,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text('How does ${scene.character} feel?',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 12),

            // 2×2 choice grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: scene.choiceIds.map((id) {
                  final e = Emotion.fromId(id) ?? Emotion.all.first;
                  final isSelected = _selected == id;
                  final isCorrect  = id == scene.correctId;
                  Color bg     = Colors.white;
                  Color border = const Color(0xFFEEEEEE);
                  if (_answered) {
                    if (isCorrect) { bg = AppTheme.greenLight; border = AppTheme.green; }
                    else if (isSelected) { bg = AppTheme.coralLight; border = AppTheme.coral; }
                  }
                  return GestureDetector(
                    onTap: () => _answer(id),
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
                          Text(e.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(e.name,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (_answered && isCorrect) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle,
                                size: 13, color: AppTheme.green),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            if (_answered)
              _FeedbackBanner(correct: _selected == scene.correctId),
          ],
        ),
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
