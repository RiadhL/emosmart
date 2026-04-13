import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';
import '../models/session_result.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // User profile
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _db.child('users/$uid').get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(snap.value as Map);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db.child('users/${profile.uid}').update(profile.toMap());
  }

  // Session results
  Future<void> saveSession(SessionResult result) async {
    final ref = _db.child('sessions/${result.userId}').push();
    await ref.set(result.toMap());

    // Update profile counters
    await _db.child('users/${result.userId}').update({
      'totalSessions': ServerValue.increment(1),
      'emotionCounts/${result.detectedEmotion}': ServerValue.increment(1),
    });
  }

  Stream<List<SessionResult>> sessionStream(String uid) {
    return _db
        .child('sessions/$uid')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map;
      return data.entries
          .map((e) => SessionResult.fromMap(e.key as String, e.value as Map))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<List<SessionResult>> getRecentSessions(String uid, {int limit = 20}) async {
    final snap = await _db
        .child('sessions/$uid')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .get();
    if (!snap.exists) return [];
    final data = snap.value as Map;
    return data.entries
        .map((e) => SessionResult.fromMap(e.key as String, e.value as Map))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
