class UserProfile {
  final String uid;
  final String name;
  final int age;
  final String avatarEmoji;
  final int totalSessions;
  final int streak;
  final Map<String, int> emotionCounts;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    this.avatarEmoji = '🌟',
    this.totalSessions = 0,
    this.streak = 0,
    Map<String, int>? emotionCounts,
  }) : emotionCounts = emotionCounts ?? {};

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'age': age,
    'avatarEmoji': avatarEmoji,
    'totalSessions': totalSessions,
    'streak': streak,
    'emotionCounts': emotionCounts,
  };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      name: map['name'] as String,
      age: (map['age'] as num).toInt(),
      avatarEmoji: map['avatarEmoji'] as String? ?? '🌟',
      totalSessions: (map['totalSessions'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      emotionCounts: Map<String, int>.from(
        (map['emotionCounts'] as Map?)?.map(
          (k, v) => MapEntry(k as String, (v as num).toInt()),
        ) ?? {},
      ),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? avatarEmoji,
    int? totalSessions,
    int? streak,
    Map<String, int>? emotionCounts,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalSessions: totalSessions ?? this.totalSessions,
      streak: streak ?? this.streak,
      emotionCounts: emotionCounts ?? this.emotionCounts,
    );
  }
}
