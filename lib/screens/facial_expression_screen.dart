import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/emotion_detector_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';

// ── Emotion task model ────────────────────────────────────────────────────────

class _EmotionTask {
  final String name;
  final String emoji;
  final String hint1; // shown after 2 failed attempts
  final String hint2; // shown after 3 failed attempts
  final Color  hintColor;

  const _EmotionTask({
    required this.name,
    required this.emoji,
    required this.hint1,
    required this.hint2,
    required this.hintColor,
  });
}

const _tasks = [
  _EmotionTask(
    name: 'Happy',
    emoji: '😊',
    hint1: 'Try smiling really big and showing your teeth! 😁',
    hint2: 'Make the biggest smile you can!',
    hintColor: Color(0xFF3DAB7B),
  ),
  _EmotionTask(
    name: 'Sad',
    emoji: '😢',
    hint1: 'Try to look down and make a frowning face 😢',
    hint2: 'Imagine something that makes you feel sad.',
    hintColor: Color(0xFF5B8DD9),
  ),
  _EmotionTask(
    name: 'Scared',
    emoji: '😱',
    hint1: 'Open your eyes really wide and raise your eyebrows! 😱',
    hint2: 'Look surprised and frightened at the same time!',
    hintColor: Color(0xFF9B59B6),
  ),
  _EmotionTask(
    name: 'Angry',
    emoji: '😠',
    hint1: 'Squeeze your eyebrows together and tighten your face 😠',
    hint2: 'Frown hard and look very serious!',
    hintColor: Color(0xFFE8604C),
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FacialExpressionScreen extends StatefulWidget {
  const FacialExpressionScreen({super.key});

  @override
  State<FacialExpressionScreen> createState() =>
      _FacialExpressionScreenState();
}

class _FacialExpressionScreenState extends State<FacialExpressionScreen>
    with SingleTickerProviderStateMixin {
  // Camera
  CameraController? _controller;
  bool _cameraReady = false;
  bool _detecting   = false;
  bool _permDenied  = false;
  String? _initError;

  // Task state
  int  _taskIndex    = 0;   // 0-3 current emotion
  int  _attempts     = 0;   // failed attempts for current task
  int  _step         = 0;   // 0=ready 1=analyzing 2=result
  bool _completed    = false;
  List<bool> _done   = [false, false, false, false];
  DetectionResult? _result;
  bool _lastCorrect  = false;

  // Services
  final _detector = EmotionDetectorService();
  final _audio    = AudioService();

  // Completion animation
  late AnimationController _celebController;
  late Animation<double>    _celebScale;

  @override
  void initState() {
    super.initState();
    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebScale = CurvedAnimation(
      parent: _celebController,
      curve: Curves.elasticOut,
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _cameraReady = false;
      _permDenied  = false;
      _initError   = null;
    });

    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _permDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _initError = 'No cameras found on this device.');
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        front,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await ctrl.initialize();
      if (!mounted) { await ctrl.dispose(); return; }

      _controller = ctrl;
      setState(() => _cameraReady = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) setState(() => _initError = 'Could not start camera.');
    }
  }

  Future<void> _takePhoto() async {
    if (_detecting || !_cameraReady || _controller == null) return;
    setState(() { _detecting = true; _step = 1; _result = null; });

    try {
      final xFile = await _controller!.takePicture();
      final result = await _detector.detectFromFile(xFile.path);
      if (!mounted) return;

      // Check if detected emotion matches current task
      final taskName = _tasks[_taskIndex].name.toLowerCase();
      final detected = result.emotionId.toLowerCase();
      final isCorrect = !result.noFace &&
                        !result.unclear &&
                        result.confidence > 0.5 &&
                        detected == taskName;

      setState(() {
        _result     = result;
        _step       = 2;
        _lastCorrect = isCorrect;
      });

      if (isCorrect) {
        await _audio.playFeedback(correct: true);
        // Wait then advance to next task
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        _advanceTask();
      } else {
        await _audio.playFeedback(correct: false);
        setState(() => _attempts++);
      }
    } catch (e) {
      debugPrint('Take photo error: $e');
      if (mounted) setState(() { _step = 0; _result = null; });
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _advanceTask() {
    final newDone = List<bool>.from(_done);
    newDone[_taskIndex] = true;

    if (_taskIndex < 3) {
      setState(() {
        _done      = newDone;
        _taskIndex++;
        _attempts  = 0;
        _step      = 0;
        _result    = null;
      });
    } else {
      setState(() {
        _done      = newDone;
        _completed = true;
      });
      _celebController.forward(from: 0);
    }
  }

  void _resetAll() {
    setState(() {
      _taskIndex = 0;
      _attempts  = 0;
      _step      = 0;
      _result    = null;
      _completed = false;
      _done      = [false, false, false, false];
      _lastCorrect = false;
    });
    _celebController.reset();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector.dispose();
    _audio.dispose();
    _celebController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildCompletionScreen();
    return _buildTaskScreen();
  }

  // ── Task screen ─────────────────────────────────────────────────────────────

  Widget _buildTaskScreen() {
    final task = _tasks[_taskIndex];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Emotion progress dots ──
            AnimatedEntrance(
              child: _EmotionProgressDots(
                currentIndex: _taskIndex,
                done: _done,
              ),
            ),
            const SizedBox(height: 18),

            // ── Task instruction ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 60),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.pinkGradient.createShader(b),
                    child: Text(
                      'Show your feeling! 😄',
                      style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: task.hintColor.withOpacity(0.12),
                      border: Border.all(
                          color: task.hintColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(task.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Text(
                          'Show me a ${task.name} face!',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: task.hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Step indicator ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 100),
              child: _StepIndicator(currentStep: _step),
            ),
            const SizedBox(height: 16),

            // ── Camera ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 160),
              child: _permDenied
                  ? _ErrorBox(
                      icon: Icons.camera_alt_outlined,
                      message:
                          'Camera permission required.\nGo to Settings → Apps → EmoSmart → Permissions.',
                      actionLabel: 'Retry',
                      onAction: _initCamera,
                    )
                  : _initError != null
                      ? _ErrorBox(
                          icon: Icons.error_outline,
                          message: _initError!,
                          actionLabel: 'Retry',
                          onAction: _initCamera,
                        )
                      : _CameraBox(
                          controller: _controller,
                          ready: _cameraReady,
                          detecting: _detecting,
                        ),
            ),
            const SizedBox(height: 16),

            // ── Adaptive hint (after 2+ fails) ──
            if (_attempts >= 2)
              AnimatedEntrance(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: task.hintColor.withOpacity(0.1),
                    border: Border.all(
                        color: task.hintColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      Text('💡',
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _attempts >= 3
                              ? task.hint2
                              : task.hint1,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: task.hintColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Visual emoji hint (after 3+ fails) ──
            if (_attempts >= 3)
              AnimatedEntrance(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: task.hintColor.withOpacity(0.15),
                    border: Border.all(
                        color: task.hintColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text('Like this!',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: task.hintColor)),
                      const SizedBox(height: 6),
                      Text(task.emoji,
                          style: const TextStyle(fontSize: 64)),
                    ],
                  ),
                ),
              ),

            // ── Result card ──
            if (_step == 2 && _result != null) ...[
              AnimatedEntrance(
                child: _ResultCard(
                  result: _result!,
                  isCorrect: _lastCorrect,
                  taskName: task.name,
                  taskEmoji: task.emoji,
                ),
              ),
              const SizedBox(height: 10),
              if (!_lastCorrect)
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 80),
                  child: GestureDetector(
                    onTap: () => setState(
                        () { _step = 0; _result = null; }),
                    child: Text(
                      'Try again',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.brandPurple,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // ── Capture button ──
            AnimatedEntrance(
              delay: const Duration(milliseconds: 240),
              child: GestureDetector(
                onTap: (_detecting ||
                        _permDenied ||
                        _initError != null ||
                        (_step == 2 && _lastCorrect))
                    ? null
                    : _takePhoto,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: (_detecting ||
                              _permDenied ||
                              _initError != null)
                          ? [
                              const Color(0xFFFF6B9D).withOpacity(0.5),
                              const Color(0xFFD4538A).withOpacity(0.5),
                            ]
                          : const [
                              Color(0xFFFF6B9D),
                              Color(0xFFD4538A),
                            ],
                    ),
                    boxShadow: (_detecting ||
                            _permDenied ||
                            _initError != null)
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFFD4538A)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _detecting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Take a photo',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Completion screen ────────────────────────────────────────────────────────

  Widget _buildCompletionScreen() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ScaleTransition(
            scale: _celebScale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppTheme.primaryGradient.createShader(b),
                  child: Text(
                    'Amazing job! 🎉',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You showed all 4 emotions perfectly!',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // 4 emotion checkmarks
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.8), width: 1.5),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _tasks.map((t) => Column(
                      children: [
                        Text(t.emoji,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF3DAB7B),
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(t.name,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary)),
                      ],
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // Play again button
                GestureDetector(
                  onTap: _resetAll,
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.brandPurple.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Play again 🔁',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Emotion progress dots ─────────────────────────────────────────────────────

class _EmotionProgressDots extends StatelessWidget {
  final int        currentIndex;
  final List<bool> done;

  const _EmotionProgressDots({
    required this.currentIndex,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tasks.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final leftDone = done[i ~/ 2];
          return Container(
            width: 32, height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: leftDone
                  ? const Color(0xFF3DAB7B)
                  : const Color(0xFFDDDDDD),
            ),
          );
        }
        final idx     = i ~/ 2;
        final isCur   = idx == currentIndex;
        final isDone  = done[idx];

        return Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF3DAB7B)
                : isCur
                    ? const Color(0xFFD4538A)
                    : const Color(0xFFF0F0F0),
            border: isCur && !isDone
                ? Border.all(color: const Color(0xFFD4538A), width: 2)
                : null,
            boxShadow: (isCur || isDone)
                ? [
                    BoxShadow(
                      color: (isDone
                              ? const Color(0xFF3DAB7B)
                              : const Color(0xFFD4538A))
                          .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    _tasks[idx].emoji,
                    style: TextStyle(
                        fontSize: isCur ? 22 : 18),
                  ),
          ),
        );
      }),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Make a face', 'Take photo', 'See result'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Container(
            width: 28, height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B9D).withOpacity(0.4),
                  const Color(0xFFD4538A).withOpacity(0.4),
                ],
              ),
            ),
          );
        }
        final idx  = i ~/ 2;
        final done = idx <= currentStep;
        return Row(
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: done
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFD4538A)])
                    : null,
                color: done ? null : const Color(0xFFEEEEEE),
                boxShadow: done
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD4538A).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '${idx + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          done ? Colors.white : AppTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              steps[idx],
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: done
                      ? const Color(0xFFD4538A)
                      : AppTheme.textSecondary,
                  fontWeight:
                      done ? FontWeight.w600 : FontWeight.w400),
            ),
          ],
        );
      }),
    );
  }
}

// ── Camera box ────────────────────────────────────────────────────────────────

class _CameraBox extends StatelessWidget {
  final CameraController? controller;
  final bool ready;
  final bool detecting;

  const _CameraBox({
    required this.controller,
    required this.ready,
    required this.detecting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4538A).withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (ready && controller != null)
              SizedBox(
                width: double.infinity,
                height: 260,
                child: CameraPreview(controller!),
              )
            else
              Container(
                width: double.infinity,
                height: 260,
                color: const Color(0xFF1A1A2E),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.pinkGradient.createShader(b),
                      child: const Icon(Icons.camera_alt_outlined,
                          size: 56, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text('Camera loading…',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white54)),
                  ],
                ),
              ),

            // Corner brackets
            ..._buildCorners(),

            if (detecting)
              Container(
                width: double.infinity,
                height: 260,
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 40, height: 40,
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF6B9D), strokeWidth: 3),
                    ),
                    const SizedBox(height: 14),
                    Text('Analyzing…',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const t = 3.0;
    const sz = 26.0;
    const pad = 14.0;
    Widget b(bool left, bool top) => Positioned(
          top:    top ? pad : null,
          bottom: !top ? pad : null,
          left:   left ? pad : null,
          right:  !left ? pad : null,
          child: SizedBox(
            width: sz, height: sz,
            child: CustomPaint(
              painter: _CornerPainter(
                  left: left,
                  top: top,
                  color: const Color(0xFFFF6B9D),
                  thickness: t),
            ),
          ),
        );
    return [b(true, true), b(false, true), b(true, false), b(false, false)];
  }
}

class _CornerPainter extends CustomPainter {
  final bool  left, top;
  final Color color;
  final double thickness;

  const _CornerPainter({
    required this.left,
    required this.top,
    required this.color,
    required this.thickness,
  });

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

// ── Error box ─────────────────────────────────────────────────────────────────

class _ErrorBox extends StatelessWidget {
  final IconData     icon;
  final String       message;
  final String       actionLabel;
  final VoidCallback onAction;

  const _ErrorBox({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppTheme.coralLight, Colors.white],
        ),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.coral.withOpacity(0.1),
            ),
            child: Icon(icon, size: 32, color: AppTheme.coral),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppTheme.coralGradient,
              ),
              child: Text(actionLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final DetectionResult result;
  final bool   isCorrect;
  final String taskName;
  final String taskEmoji;

  const _ResultCard({
    required this.result,
    required this.isCorrect,
    required this.taskName,
    required this.taskEmoji,
  });

  @override
  Widget build(BuildContext context) {
    if (result.noFace) {
      return _card(
        gradient: AppTheme.coralGradient,
        icon: Icons.face_outlined,
        title: 'No face detected! 😕',
        subtitle: 'Make sure your face is fully visible in the frame.',
        isSuccess: false,
      );
    }

    if (!isCorrect) {
      return _card(
        gradient: AppTheme.coralGradient,
        icon: Icons.refresh_rounded,
        title: 'Try again! 🔄',
        subtitle:
            'Show a bigger $taskName expression! $taskEmoji',
        isSuccess: false,
      );
    }

    final pct = (result.confidence * 100).round();
    return _card(
      gradient: AppTheme.greenGradient,
      icon: Icons.check_circle_outline,
      title: 'Great job! 🌟',
      subtitle: null,
      badge: '$taskName $taskEmoji',
      badgeNote: '$pct% confident',
      isSuccess: true,
    );
  }

  Widget _card({
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String? subtitle,
    required bool isSuccess,
    String? badge,
    String? badgeNote,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withOpacity(0.1),
            gradient.colors.last.withOpacity(0.05),
          ],
        ),
        border: Border(
          left: BorderSide(color: gradient.colors.first, width: 4),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
                ],
                if (badge != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(badge,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      if (badgeNote != null) ...[
                        const SizedBox(width: 8),
                        Text(badgeNote,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
