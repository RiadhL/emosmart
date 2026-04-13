class Emotion {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String level; // 'easy' | 'medium' | 'hard'

  const Emotion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
  });

  // ── Easy emotions (Level 1) ───────────────────────────────────────────────
  static const List<Emotion> easy = [
    Emotion(id: 'happy',     name: 'Happy',     emoji: '😊', description: 'Feeling joyful and good!',             level: 'easy'),
    Emotion(id: 'sad',       name: 'Sad',       emoji: '😢', description: 'Feeling unhappy or upset.',            level: 'easy'),
    Emotion(id: 'angry',     name: 'Angry',     emoji: '😠', description: 'Feeling mad or frustrated.',           level: 'easy'),
    Emotion(id: 'fear',      name: 'Scared',    emoji: '😨', description: 'Feeling afraid or worried.',           level: 'easy'),
    Emotion(id: 'disgust',   name: 'Disgusted', emoji: '🤢', description: 'Feeling yucky or grossed out.',        level: 'easy'),
    Emotion(id: 'surprised', name: 'Surprised', emoji: '😲', description: 'Feeling shocked or amazed!',           level: 'easy'),
  ];

  // ── Medium emotions (Level 2) ─────────────────────────────────────────────
  static const List<Emotion> medium = [
    Emotion(id: 'frustrated',  name: 'Frustrated', emoji: '😤', description: 'Feeling blocked or upset.',          level: 'medium'),
    Emotion(id: 'worried',     name: 'Worried',    emoji: '😟', description: 'Feeling anxious about something.',   level: 'medium'),
    Emotion(id: 'calm',        name: 'Calm',       emoji: '😌', description: 'Feeling peaceful and relaxed.',      level: 'medium'),
    Emotion(id: 'bored',       name: 'Bored',      emoji: '😑', description: 'Feeling uninterested.',              level: 'medium'),
    Emotion(id: 'tired',       name: 'Tired',      emoji: '😴', description: 'Feeling sleepy or exhausted.',       level: 'medium'),
    Emotion(id: 'confused',    name: 'Confused',   emoji: '😕', description: 'Not sure what is happening.',        level: 'medium'),
    Emotion(id: 'guilty',      name: 'Guilty',     emoji: '😔', description: 'Feeling bad about something done.',  level: 'medium'),
    Emotion(id: 'nervous',     name: 'Nervous',    emoji: '😰', description: 'Feeling jittery before something.',  level: 'medium'),
  ];

  // ── Hard emotions (Level 3) ───────────────────────────────────────────────
  static const List<Emotion> hard = [
    Emotion(id: 'suspicious',   name: 'Suspicious',   emoji: '🤨', description: 'Feeling like something is off.',     level: 'hard'),
    Emotion(id: 'disappointed', name: 'Disappointed', emoji: '😞', description: 'Expected more but got less.',        level: 'hard'),
    Emotion(id: 'jealous',      name: 'Jealous',      emoji: '😒', description: 'Wanting what someone else has.',     level: 'hard'),
    Emotion(id: 'ashamed',      name: 'Ashamed',      emoji: '😳', description: 'Feeling embarrassed by something.',  level: 'hard'),
    Emotion(id: 'lonely',       name: 'Lonely',       emoji: '🥺', description: 'Feeling alone and left out.',        level: 'hard'),
  ];

  static List<Emotion> get all => [...easy, ...medium, ...hard];

  static Emotion? fromId(String id) {
    try { return all.firstWhere((e) => e.id == id); }
    catch (_) { return null; }
  }

  static List<Emotion> forGameLevel(int level) {
    switch (level) {
      case 1: return easy;
      case 2: return medium;
      case 3: return hard;
      default: return easy;
    }
  }
}
