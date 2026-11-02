import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/nokia_colors.dart';
import '../../domain/models/maze.dart';
import '../../domain/repositories/i_game_settings_repository.dart';

class GameSettingsRepository implements IGameSettingsRepository {
  static const String _levelKey = 'nokia_snake_level';
  static const String _mazeKey = 'nokia_snake_maze';
  static const String _soundKey = 'nokia_snake_sound';
  static const String _vibrationKey = 'nokia_snake_vibration';
  static const String _themeKey = 'nokia_snake_theme';
  static const String _backlightKey = 'nokia_snake_backlight';

  @override
  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 4; // Default level 4
  }

  @override
  Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
  }

  @override
  Future<MazeType> getMazeType() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_mazeKey);
    if (name == null) return MazeType.openBorder;
    return MazeType.values.firstWhere(
      (m) => m.name == name,
      orElse: () => MazeType.openBorder,
    );
  }

  @override
  Future<void> saveMazeType(MazeType mazeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mazeKey, mazeType.name);
  }

  @override
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  @override
  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  @override
  Future<void> saveVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  @override
  Future<ScreenTheme> getScreenTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_themeKey);
    if (name == null) return ScreenTheme.classicGreen;
    return ScreenTheme.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ScreenTheme.classicGreen,
    );
  }

  @override
  Future<void> saveScreenTheme(ScreenTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }

  @override
  Future<bool> getBacklightOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backlightKey) ?? true;
  }

  @override
  Future<void> saveBacklightOn(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backlightKey, on);
  }
}
