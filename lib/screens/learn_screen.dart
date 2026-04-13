import 'package:flutter/material.dart';
import '../models/emotion.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _currentIndex = 0;
  final AudioService _audio = AudioService();

  Emotion get _current => Emotion.all[_currentIndex];

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => _currentIndex = (_currentIndex + 1) % Emotion.all.length);
  }

  void _previous() {
    setState(() => _currentIndex =
        (_currentIndex - 1 + Emotion.all.length) % Emotion.all.length);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.emotionColor(_current.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Learn Emotions')),
      body: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: color.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_current.emoji, style: const TextStyle(fontSize: 100)),
                    const SizedBox(height: 16),
                    Text(_current.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: color)),
                    const SizedBox(height: 8),
                    Text(_current.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _audio.playEmotionSound(_current.id),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Hear it!'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filled(
                  onPressed: _previous,
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                ),
                Text(
                  '${_currentIndex + 1} / ${Emotion.all.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton.filled(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
