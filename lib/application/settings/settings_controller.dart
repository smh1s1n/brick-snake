import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/nokia_colors.dart';
import '../../domain/models/maze.dart';
import '../../domain/repositories/i_game_settings_repository.dart';
import '../providers.dart';

class SettingsController extends Notifier<SettingsState> {
  IGameSettingsRepository get _repository => ref.read(gameSettingsRepositoryProvider);

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState(
      level: 4,
      mazeType: MazeType.openBorder,
      soundEnabled: true,
      vibrationEnabled: true,
      theme: ScreenTheme.classicGreen,
      backlightOn: true,
    );
  }

  Future<void> _loadSettings() async {
    final level = await _repository.getLevel();
    final mazeType = await _repository.getMazeType();
    final sound = await _repository.getSoundEnabled();
    final vibration = await _repository.getVibrationEnabled();
    final theme = await _repository.getScreenTheme();
    final backlight = await _repository.getBacklightOn();

    ref.read(audioServiceProvider).soundEnabled = sound;

    state = SettingsState(
      level: level,
      mazeType: mazeType,
      soundEnabled: sound,
      vibrationEnabled: vibration,
      theme: theme,
      backlightOn: backlight,
    );
  }

  Future<void> setLevel(int level) async {
    state = state.copyWith(level: level);
    await _repository.saveLevel(level);
  }

  Future<void> setMazeType(MazeType mazeType) async {
    state = state.copyWith(mazeType: mazeType);
    await _repository.saveMazeType(mazeType);
  }

  Future<void> toggleSound() async {
    final newSound = !state.soundEnabled;
    state = state.copyWith(soundEnabled: newSound);
    ref.read(audioServiceProvider).soundEnabled = newSound;
    await _repository.saveSoundEnabled(newSound);
  }

  Future<void> toggleVibration() async {
    final newVib = !state.vibrationEnabled;
    state = state.copyWith(vibrationEnabled: newVib);
    await _repository.saveVibrationEnabled(newVib);
  }

  Future<void> setTheme(ScreenTheme theme) async {
    state = state.copyWith(theme: theme);
    await _repository.saveScreenTheme(theme);
  }

  Future<void> toggleBacklight() async {
    final newBacklight = !state.backlightOn;
    state = state.copyWith(backlightOn: newBacklight);
    await _repository.saveBacklightOn(newBacklight);
  }
}
