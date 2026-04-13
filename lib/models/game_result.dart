class GameResult {
  final String gameId; // 'mood_match' | 'feeling_stories' | 'pattern_fun'
  final int level;
  final int score;
  final int maxScore;
  final int errors;
  final int starsEarned;
  final Duration timeTaken;
  final DateTime completedAt;

  GameResult({
    required this.gameId,
    required this.level,
    required this.score,
    required this.maxScore,
    this.errors = 0,
    required this.starsEarned,
    required this.timeTaken,
    required this.completedAt,
  });

  double get percentage => maxScore > 0 ? score / maxScore : 0;

  Map<String, dynamic> toMap() => {
    'gameId': gameId,
    'level': level,
    'score': score,
    'maxScore': maxScore,
    'errors': errors,
    'starsEarned': starsEarned,
    'timeTaken': timeTaken.inSeconds,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  factory GameResult.fromMap(Map<dynamic, dynamic> map) {
    final ts = map['completedAt'];
    final completedAt = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return GameResult(
      gameId:       map['gameId']     as String? ?? '',
      level:        (map['level']     as num?)?.toInt() ?? 1,
      score:        (map['score']     as num?)?.toInt() ?? 0,
      maxScore:     (map['maxScore']  as num?)?.toInt() ?? 12,
      errors:       (map['errors']    as num?)?.toInt() ?? 0,
      starsEarned:  (map['starsEarned'] as num?)?.toInt() ?? 0,
      timeTaken:    Duration(seconds: (map['timeTaken'] as num?)?.toInt() ?? 0),
      completedAt:  completedAt,
    );
  }
}
