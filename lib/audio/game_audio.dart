import 'package:flame_audio/flame_audio.dart';

/// Kenney CC0 audio — kenney.nl
abstract final class GameAudio {
  static bool _ready = false;
  static const double _bgmVolume = 0.22;

  static Future<void> preload() async {
    if (_ready) return;
    await FlameAudio.audioCache.loadAll([
      'drop.wav',
      'land.wav',
      'perfect.wav',
      'game_over.wav',
      'ambient.wav',
    ]);
    await FlameAudio.bgm.initialize(
      audioContext: AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
      ).build(),
    );
    _ready = true;
  }

  static Future<void> startMusic() async {
    if (!_ready || FlameAudio.bgm.isPlaying) return;
    await FlameAudio.bgm.play('ambient.wav', volume: _bgmVolume);
  }

  static void _play(String file) {
    if (!_ready) return;
    FlameAudio.play(file);
  }

  static void drop() => _play('drop.wav');
  static void land() => _play('land.wav');
  static void perfect() => _play('perfect.wav');
  static void gameOver() => _play('game_over.wav');
}
