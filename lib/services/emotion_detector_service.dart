import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class EmotionDetectorService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // smilingProbability + eyeOpenProbability
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Detect one of 4 emotions (happy, sad, scared, angry) from a photo file.
  Future<DetectionResult> detectFromFile(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final faces      = await _detector.processImage(inputImage);

      if (faces.isEmpty) {
        return const DetectionResult(
          emotionId:  '',
          emoji:      '😕',
          label:      'No face detected',
          confidence: 0,
          noFace:     true,
          unclear:    false,
        );
      }

      final face     = faces.first;
      final smiling  = face.smilingProbability          ?? 0.5;
      final leftEye  = face.leftEyeOpenProbability      ?? 0.7;
      final rightEye = face.rightEyeOpenProbability     ?? 0.7;
      final eulerZ   = (face.headEulerAngleZ ?? 0.0).abs();
      final avgEye   = (leftEye + rightEye) / 2.0;

      // ── Priority-ordered emotion mapping ───────────────────────────────────
      //
      // HAPPY  : strong smile
      // SCARED : wide eyes, no smile
      // ANGRY  : not smiling, eyes narrowed, head level
      // SAD    : not smiling, eyes open, head level
      // unclear: face detected but none of the above matched clearly

      if (smiling > 0.65) {
        return DetectionResult(
          emotionId:  'Happy',
          emoji:      '😊',
          label:      'Happy 😊',
          confidence: smiling.clamp(0.0, 1.0),
          noFace:     false,
          unclear:    false,
        );
      }

      if (leftEye > 0.85 && rightEye > 0.85 && smiling < 0.3) {
        final conf = avgEye.clamp(0.0, 1.0);
        return DetectionResult(
          emotionId:  'Scared',
          emoji:      '😱',
          label:      'Scared 😱',
          confidence: conf,
          noFace:     false,
          unclear:    false,
        );
      }

      if (smiling < 0.2 && leftEye < 0.6 && rightEye < 0.6 && eulerZ < 15) {
        final conf = ((1.0 - smiling) * 0.5 + (1.0 - avgEye) * 0.5)
            .clamp(0.0, 1.0);
        return DetectionResult(
          emotionId:  'Angry',
          emoji:      '😠',
          label:      'Angry 😠',
          confidence: conf,
          noFace:     false,
          unclear:    false,
        );
      }

      if (smiling < 0.2 && leftEye > 0.5 && rightEye > 0.5 && eulerZ < 15) {
        final conf = ((1.0 - smiling) * 0.5 + avgEye * 0.25)
            .clamp(0.0, 1.0);
        return DetectionResult(
          emotionId:  'Sad',
          emoji:      '😢',
          label:      'Sad 😢',
          confidence: conf,
          noFace:     false,
          unclear:    false,
        );
      }

      // Face detected but expression was not clear enough
      return const DetectionResult(
        emotionId:  '',
        emoji:      '😐',
        label:      'Unclear',
        confidence: 0,
        noFace:     false,
        unclear:    true,
      );
    } catch (e) {
      return const DetectionResult(
        emotionId:  '',
        emoji:      '😕',
        label:      'Detection error',
        confidence: 0,
        noFace:     true,
        unclear:    false,
      );
    }
  }

  void dispose() => _detector.close();
}

class DetectionResult {
  final String emotionId;   // e.g. 'Happy'
  final String emoji;
  final String label;       // e.g. 'Happy 😊'
  final double confidence;  // 0.0–1.0
  final bool   noFace;      // true when no face was found in the image
  final bool   unclear;     // true when face found but no emotion matched

  const DetectionResult({
    required this.emotionId,
    required this.emoji,
    required this.label,
    required this.confidence,
    required this.noFace,
    required this.unclear,
  });
}
