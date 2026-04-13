class SessionResult {
  final String id;
  final String userId;
  final String detectedEmotion;
  final double confidence;
  final DateTime timestamp;
  final String sessionType; // 'detection' | 'quiz' | 'learn'

  SessionResult({
    required this.id,
    required this.userId,
    required this.detectedEmotion,
    required this.confidence,
    required this.timestamp,
    required this.sessionType,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'detectedEmotion': detectedEmotion,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'sessionType': sessionType,
  };

  factory SessionResult.fromMap(String id, Map<dynamic, dynamic> map) {
    return SessionResult(
      id: id,
      userId: map['userId'] as String,
      detectedEmotion: map['detectedEmotion'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      sessionType: map['sessionType'] as String,
    );
  }
}
