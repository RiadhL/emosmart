import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _detectedEmotion;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    // Prefer front camera for emotion detection
    final front = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    _controller = CameraController(front, ResolutionPreset.medium,
        enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndDetect() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    // TODO: capture image and run emotion detection model
    // For now, show a placeholder result
    setState(() => _detectedEmotion = 'happy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detect My Emotion')),
      body: Column(
        children: [
          Expanded(
            child: _isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CameraPreview(_controller!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          if (_detectedEmotion != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.emotionColor(_detectedEmotion!).withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.face, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'I see: $_detectedEmotion!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _captureAndDetect,
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text('Detect Emotion'),
            ),
          ),
        ],
      ),
    );
  }
}
