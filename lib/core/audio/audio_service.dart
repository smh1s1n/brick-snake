import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'sound_generator.dart';

abstract class IAudioService {
  Future<void> init();
  Future<void> playKeyClick();
  Future<void> playEatFood();
  Future<void> playBonusSpawn();
  Future<void> playEatBonus();
  Future<void> playCrash();
  Future<void> playHighScore();
  void dispose();
}

class AudioService implements IAudioService {
  AudioService() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
  }

  late final AudioPlayer _player;
  bool soundEnabled = true;

  Uint8List? _keyClickWav;
  Uint8List? _eatFoodWav;
  Uint8List? _bonusSpawnWav;
  Uint8List? _eatBonusWav;
  Uint8List? _crashWav;
  Uint8List? _highScoreWav;

  @override
  Future<void> init() async {
    try {
      _keyClickWav = SoundGenerator.keyClick();
      _eatFoodWav = SoundGenerator.eatFood();
      _bonusSpawnWav = SoundGenerator.bonusSpawn();
      _eatBonusWav = SoundGenerator.eatBonus();
      _crashWav = SoundGenerator.crash();
      _highScoreWav = SoundGenerator.highScoreFanfare();
    } catch (e) {
      debugPrint('Error generating audio: $e');
    }
  }

  Future<void> _playBytes(Uint8List? bytes) async {
    if (!soundEnabled || bytes == null) return;
    try {
      await _player.stop();
      await _player.play(BytesSource(bytes));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  @override
  Future<void> playKeyClick() => _playBytes(_keyClickWav);

  @override
  Future<void> playEatFood() => _playBytes(_eatFoodWav);

  @override
  Future<void> playBonusSpawn() => _playBytes(_bonusSpawnWav);

  @override
  Future<void> playEatBonus() => _playBytes(_eatBonusWav);

  @override
  Future<void> playCrash() => _playBytes(_crashWav);

  @override
  Future<void> playHighScore() => _playBytes(_highScoreWav);

  @override
  void dispose() {
    _player.dispose();
  }
}
