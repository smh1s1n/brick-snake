import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/nokia_colors.dart';
import '../domain/models/maze.dart';
import '../domain/repositories/i_game_settings_repository.dart';
import '../domain/repositories/i_high_score_repository.dart';
import '../infrastructure/repositories/game_settings_repository.dart';
import '../infrastructure/repositories/high_score_repository.dart';
import 'game/game_controller.dart';
import 'game/game_session_state.dart';
import 'settings/settings_controller.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final highScoreRepositoryProvider = Provider<IHighScoreRepository>((ref) {
  return HighScoreRepository();
});

final gameSettingsRepositoryProvider = Provider<IGameSettingsRepository>((ref) {
  return GameSettingsRepository();
});

class SettingsState {
  final int level;
  final MazeType mazeType;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ScreenTheme theme;
  final bool backlightOn;

  const SettingsState({
    required this.level,
    required this.mazeType,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.theme,
    required this.backlightOn,
  });

  SettingsState copyWith({
    int? level,
    MazeType? mazeType,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ScreenTheme? theme,
    bool? backlightOn,
  }) {
    return SettingsState(
      level: level ?? this.level,
      mazeType: mazeType ?? this.mazeType,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
      backlightOn: backlightOn ?? this.backlightOn,
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

final gameControllerProvider =
    NotifierProvider<GameController, GameSessionState>(GameController.new);
