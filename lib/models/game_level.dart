class GameLevel {
  final int level;
  final String title;
  final String description;
  final int stars; // 0-3, earned by user
  final bool unlocked;
  final LevelDifficulty difficulty;

  const GameLevel({
    required this.level,
    required this.title,
    required this.description,
    this.stars = 0,
    this.unlocked = false,
    required this.difficulty,
  });

  GameLevel copyWith({int? stars, bool? unlocked}) => GameLevel(
        level: level,
        title: title,
        description: description,
        stars: stars ?? this.stars,
        unlocked: unlocked ?? this.unlocked,
        difficulty: difficulty,
      );

  Map<String, dynamic> toMap() => {
        'level': level,
        'stars': stars,
        'unlocked': unlocked,
      };

  factory GameLevel.fromMap(Map<dynamic, dynamic> map, GameLevel base) =>
      base.copyWith(
        stars: (map['stars'] as num?)?.toInt() ?? 0,
        unlocked: map['unlocked'] as bool? ?? false,
      );
}

enum LevelDifficulty { easy, medium, hard }
