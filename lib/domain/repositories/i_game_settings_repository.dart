import '../../core/constants/nokia_colors.dart';
import '../models/maze.dart';

abstract class IGameSettingsRepository {
  Future<int> getLevel();
  Future<void> saveLevel(int level);

  Future<MazeType> getMazeType();
  Future<void> saveMazeType(MazeType mazeType);

  Future<bool> getSoundEnabled();
  Future<void> saveSoundEnabled(bool enabled);

  Future<bool> getVibrationEnabled();
  Future<void> saveVibrationEnabled(bool enabled);

  Future<ScreenTheme> getScreenTheme();
  Future<void> saveScreenTheme(ScreenTheme theme);

  Future<bool> getBacklightOn();
  Future<void> saveBacklightOn(bool on);
}
