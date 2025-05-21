import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playLoop(String assetPath) async {
    await _player.stop();
    await _player.setSourceAsset(assetPath);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.resume();
    _isPlaying = true;
  }

  static Future<void> stop() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
    }
  }
}
