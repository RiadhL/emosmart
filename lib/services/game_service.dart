import 'package:firebase_database/firebase_database.dart';
import '../models/game_result.dart';
import '../models/game_level.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ── Level definitions ──────────────────────────────────────────────────────

  static List<GameLevel> levelsFor(String gameId) {
    final configs = _levelConfigs[gameId] ?? [];
    return configs;
  }

  static const Map<String, List<GameLevel>> _levelConfigs = {
    'mood_match': [
      GameLevel(level: 1, title: 'Level 1', description: '4 cards · 2 emotions', unlocked: true, difficulty: LevelDifficulty.easy),
      GameLevel(level: 2, title: 'Level 2', description: '8 cards · 4 emotions', difficulty: LevelDifficulty.easy),
      GameLevel(level: 3, title: 'Level 3', description: '12 cards · 6 emotions', difficulty: LevelDifficulty.medium),
      GameLevel(level: 4, title: 'Level 4', description: '16 cards · timed!', difficulty: LevelDifficulty.hard),
    ],
    'feeling_stories': [
      GameLevel(level: 1, title: 'Level 1', description: '2 simple stories', unlocked: true, difficulty: LevelDifficulty.easy),
      GameLevel(level: 2, title: 'Level 2', description: '3 medium stories', difficulty: LevelDifficulty.medium),
      GameLevel(level: 3, title: 'Level 3', description: '4 tricky stories', difficulty: LevelDifficulty.hard),
    ],
    'pattern_fun': [
      GameLevel(level: 1, title: 'Level 1', description: 'AB patterns · 4 faces', unlocked: true, difficulty: LevelDifficulty.easy),
      GameLevel(level: 2, title: 'Level 2', description: 'ABC patterns · 6 faces', difficulty: LevelDifficulty.easy),
      GameLevel(level: 3, title: 'Level 3', description: 'AABB patterns', difficulty: LevelDifficulty.medium),
      GameLevel(level: 4, title: 'Level 4', description: 'Mixed patterns · timed!', difficulty: LevelDifficulty.hard),
    ],
  };

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> saveResult(String uid, GameResult result) async {
    final ref = _db.child('game_results/$uid/${result.gameId}').push();
    await ref.set(result.toMap());

    // Unlock next level if stars earned
    if (result.starsEarned > 0) {
      await _db
          .child('user_levels/$uid/${result.gameId}/${result.level}')
          .update({'stars': result.starsEarned, 'unlocked': true});
      // Unlock next level
      await _db
          .child('user_levels/$uid/${result.gameId}/${result.level + 1}')
          .update({'unlocked': true});
    }
  }

  Future<List<GameResult>> getResultsForGame(String uid, String gameId) async {
    final snap = await _db.child('game_results/$uid/$gameId').get();
    if (!snap.exists) return [];
    final data = snap.value as Map;
    return data.entries
        .map((e) => GameResult.fromMap(e.value as Map))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<List<GameResult>> getAllRecentResults(String uid, {int limit = 5}) async {
    const games = ['mood_match', 'feeling_stories', 'pattern_fun'];
    final all = <GameResult>[];
    for (final g in games) {
      all.addAll(await getResultsForGame(uid, g));
    }
    all.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return all.take(limit).toList();
  }

  Future<Map<int, int>> getStarsFor(String uid, String gameId) async {
    final snap = await _db.child('user_levels/$uid/$gameId').get();
    if (!snap.exists) return {};
    final data = snap.value as Map;
    return data.map((k, v) =>
        MapEntry(int.parse(k.toString()), (v as Map)['stars'] as int? ?? 0));
  }

  Future<Set<int>> getUnlockedLevels(String uid, String gameId) async {
    final snap = await _db.child('user_levels/$uid/$gameId').get();
    final unlocked = <int>{1}; // level 1 always unlocked
    if (!snap.exists) return unlocked;
    final data = snap.value as Map;
    for (final entry in data.entries) {
      if ((entry.value as Map)['unlocked'] == true) {
        unlocked.add(int.parse(entry.key.toString()));
      }
    }
    return unlocked;
  }

  int starsForScore(double pct) {
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    if (pct >= 0.3) return 1;
    return 0;
  }
}
