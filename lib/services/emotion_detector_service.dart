import 'package:camera/camera.dart';

/// Stub emotion detector — replace body with a real ML model (e.g. tflite_flutter)
/// when the model file is available. The interface is stable so callers don't change.
class EmotionDetectorService {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Analyse a camera [image] and return a [DetectionResult].
  /// Returns null if detection fails or the service is busy.
  Future<DetectionResult?> detect(CameraImage image) async {
    if (_isRunning) return null;
    _isRunning = true;
    try {
      // TODO: run real inference here (tflite / google_mlkit_face_detection)
      // For now return a simulated result after a short delay.
      await Future.delayed(const Duration(milliseconds: 400));
      final emotions = _simulateScores();
      final best = emotions.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      return DetectionResult(
        emotionId: best.key,
        confidence: best.value,
        allScores: emotions,
      );
    } finally {
      _isRunning = false;
    }
  }

  Map<String, double> _simulateScores() {
    // Placeholder: uniform low confidence across emotions
    return {
      'happy': 0.15,
      'sad': 0.10,
      'angry': 0.08,
      'surprised': 0.12,
      'fear': 0.07,
      'neutral': 0.48,
    };
  }

  void dispose() {}
}

class DetectionResult {
  final String emotionId;
  final double confidence;
  final Map<String, double> allScores;

  const DetectionResult({
    required this.emotionId,
    required this.confidence,
    required this.allScores,
  });
}
