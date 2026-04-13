import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/emotion_detector_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class FacialExpressionScreen extends StatefulWidget {
  const FacialExpressionScreen({super.key});

  @override
  State<FacialExpressionScreen> createState() =>
      _FacialExpressionScreenState();
}

class _FacialExpressionScreenState extends State<FacialExpressionScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _detecting   = false;

  int _step = 0; // 0=ready, 1=detecting, 2=result
  DetectionResult? _result;

  final _detector = EmotionDetectorService();
  final _audio    = AudioService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    if (cams.isEmpty) return;
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );
    _camera = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _takePhoto() async {
    if (_detecting || !_cameraReady) return;
    setState(() { _detecting = true; _step = 1; _result = null; });

    try {
      await _camera!.takePicture();
      // Stub detection — replace with real ML call
      final detected = DetectionResult(
        emotionId: 'happy',
        confidence: 0.82,
        allScores: {},
      );
      setState(() { _result = detected; _step = 2; });
      await _audio.playFeedback(correct: true);
    } catch (_) {
      setState(() => _step = 0);
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _detector.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Show your feeling! 😄',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text(
              'Make a face, take a photo, and we\'ll guess your emotion!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // ── Step indicator ──────────────────────────────────────────
            _StepIndicator(currentStep: _step),
            const SizedBox(height: 20),

            // ── Camera viewfinder ───────────────────────────────────────
            _CameraBox(
              camera: _camera,
              ready: _cameraReady,
              detecting: _detecting,
            ),
            const SizedBox(height: 20),

            // ── Result card ─────────────────────────────────────────────
            if (_step == 2 && _result != null)
              _ResultCard(result: _result!),

            if (_step != 2)
              const Spacer(),

            // ── Button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _detecting ? null : _takePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius)),
                ),
                child: _detecting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📸 Take a photo',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
              ),
            ),

            if (_step == 2) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() { _step = 0; _result = null; }),
                child: const Text('Try again',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.brandPurple,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep; // 0, 1, 2

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Make a face', 'Take photo', 'See result'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          return Container(
            width: 28, height: 1.5,
            color: const Color(0xFFDDDDDD),
          );
        }
        final stepIdx = i ~/ 2;
        final done    = stepIdx <= currentStep;
        return Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppTheme.brandPurple : const Color(0xFFEEEEEE),
              ),
              child: Center(
                child: Text('${stepIdx + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: done ? Colors.white : AppTheme.textSecondary)),
              ),
            ),
            const SizedBox(width: 4),
            Text(steps[stepIdx],
                style: TextStyle(
                    fontSize: 10,
                    color: done ? AppTheme.brandPurple : AppTheme.textSecondary,
                    fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
          ],
        );
      }),
    );
  }
}

// ── Camera viewfinder ─────────────────────────────────────────────────────────

class _CameraBox extends StatelessWidget {
  final CameraController? camera;
  final bool ready;
  final bool detecting;

  const _CameraBox({required this.camera, required this.ready, required this.detecting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.pink.withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.5),
      ),
      child: Stack(
        children: [
          // Camera preview or placeholder
          if (ready && camera != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox.expand(child: CameraPreview(camera!)),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 40,
                      color: AppTheme.pink.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Camera loading…',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                ],
              ),
            ),
          // Corner brackets (pink)
          ..._corners(AppTheme.pink),
          // Detecting overlay
          if (detecting)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.pink),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _corners(Color c) {
    const t = 2.5;
    const sz = 18.0;
    const pad = 10.0;

    Widget bracket(bool left, bool top) => Positioned(
      top:    top  ? pad : null,
      bottom: !top ? pad : null,
      left:   left ? pad : null,
      right:  !left? pad : null,
      child: SizedBox(
        width: sz, height: sz,
        child: CustomPaint(
          painter: _CornerP(left: left, top: top, color: c, thickness: t),
        ),
      ),
    );

    return [
      bracket(true,  true),
      bracket(false, true),
      bracket(true,  false),
      bracket(false, false),
    ];
  }
}

class _CornerP extends CustomPainter {
  final bool left;
  final bool top;
  final Color color;
  final double thickness;
  const _CornerP({required this.left, required this.top,
      required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x  = left ? 0.0 : size.width;
    final y  = top  ? 0.0 : size.height;
    final dx = left ? size.width  : -size.width;
    final dy = top  ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final DetectionResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final success = result.confidence > 0.5;
    final bg     = success ? AppTheme.greenLight : AppTheme.coralLight;
    final border = success ? AppTheme.green      : AppTheme.coral;
    final label  = success ? 'You\'re doing great!'   : 'Try again!';
    final sub    = success
        ? 'We detected: ${result.emotionId}'
        : 'Hold still and try a bigger expression';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(success ? Icons.check_circle_outline : Icons.refresh_rounded,
              color: border, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: border)),
                const SizedBox(height: 2),
                if (success)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('We detected: ',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: border.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(result.emotionId,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: border)),
                      ),
                    ],
                  )
                else
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
