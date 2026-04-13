import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playEmotionSound(String emotionId) async {
    await _player.stop();
    await _player.play(AssetSource('audio/$emotionId.mp3'));
  }

  Future<void> playFeedback({bool correct = true}) async {
    await _player.stop();
    final asset = correct ? 'sounds/correct.mp3' : 'sounds/wrong.mp3';
    await _player.play(AssetSource(asset));
  }

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
