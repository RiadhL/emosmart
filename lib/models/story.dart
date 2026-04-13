class Story {
  final String id;
  final String title;
  final String text;
  final String imageEmoji;
  final String correctEmotion;
  final List<String> choices;
  final String explanation;
  final int level;

  const Story({
    required this.id,
    required this.title,
    required this.text,
    required this.imageEmoji,
    required this.correctEmotion,
    required this.choices,
    required this.explanation,
    required this.level,
  });

  static const List<Story> all = [
    Story(
      id: 's1',
      title: 'Birthday Surprise',
      text: 'Mia woke up and saw balloons everywhere. Her family sang to her and gave her a big cake. She could not stop smiling!',
      imageEmoji: '🎂',
      correctEmotion: 'happy',
      choices: ['happy', 'sad', 'angry', 'scared'],
      explanation: 'Mia is happy because it is her birthday and everyone is celebrating!',
      level: 1,
    ),
    Story(
      id: 's2',
      title: 'Lost Toy',
      text: 'Tom could not find his favourite teddy bear anywhere. He looked under his bed and in his toy box, but it was gone.',
      imageEmoji: '🧸',
      correctEmotion: 'sad',
      choices: ['happy', 'sad', 'surprised', 'angry'],
      explanation: 'Tom is sad because he lost something he loves very much.',
      level: 1,
    ),
    Story(
      id: 's3',
      title: 'Broken Crayon',
      text: 'Jake was drawing carefully when his brother grabbed his crayons and broke them. Jake felt his face get hot and red.',
      imageEmoji: '🖍️',
      correctEmotion: 'angry',
      choices: ['sad', 'angry', 'happy', 'surprised'],
      explanation: 'Jake is angry because his brother broke his crayons without asking.',
      level: 1,
    ),
    Story(
      id: 's4',
      title: 'Big Spider',
      text: 'Emma saw a huge spider on the wall right next to her hand. Her heart started beating very fast and she jumped back.',
      imageEmoji: '🕷️',
      correctEmotion: 'fear',
      choices: ['angry', 'happy', 'fear', 'surprised'],
      explanation: 'Emma is scared because she did not expect the spider to be so close.',
      level: 2,
    ),
    Story(
      id: 's5',
      title: 'Secret Party',
      text: 'Leo opened the door and everyone yelled "SURPRISE!" He did not know about the party at all and his eyes went wide.',
      imageEmoji: '🎉',
      correctEmotion: 'surprised',
      choices: ['happy', 'surprised', 'sad', 'fear'],
      explanation: 'Leo is surprised because he did not expect the party at all!',
      level: 2,
    ),
    Story(
      id: 's6',
      title: 'Quiet Afternoon',
      text: 'Sara sat by the window reading her book. It was a calm, sunny day. She felt peaceful and relaxed.',
      imageEmoji: '📖',
      correctEmotion: 'neutral',
      choices: ['angry', 'neutral', 'sad', 'surprised'],
      explanation: 'Sara feels calm and neutral — not too excited, not upset.',
      level: 3,
    ),
  ];

  static List<Story> byLevel(int level) => all.where((s) => s.level == level).toList();
}
