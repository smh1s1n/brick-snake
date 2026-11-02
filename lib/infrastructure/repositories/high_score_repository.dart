import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/high_score.dart';
import '../../domain/models/maze.dart';
import '../../domain/repositories/i_high_score_repository.dart';

class HighScoreRepository implements IHighScoreRepository {
  static const String _highScoreKeyPrefix = 'nokia_snake_highscore_';
  static const String _allScoresKey = 'nokia_snake_all_scores';

  @override
  Future<int> getHighScoreForMaze(MazeType mazeType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_highScoreKeyPrefix${mazeType.name}') ?? 0;
  }

  @override
  Future<List<HighScore>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_allScoresKey) ?? [];
    return jsonList
        .map((s) => HighScore.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  @override
  Future<bool> saveHighScore(HighScore highScore) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getHighScoreForMaze(highScore.mazeType);
    bool isNewRecord = false;

    if (highScore.score > currentBest) {
      await prefs.setInt('$_highScoreKeyPrefix${highScore.mazeType.name}', highScore.score);
      isNewRecord = true;
    }

    // Also persist in global scores list
    final all = await getAllHighScores();
    all.add(highScore);
    all.sort((a, b) => b.score.compareTo(a.score));
    // Keep top 20 scores
    final trimmed = all.take(20).toList();
    final encoded = trimmed.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_allScoresKey, encoded);

    return isNewRecord;
  }

  @override
  Future<void> clearAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    for (final maze in MazeType.values) {
      await prefs.remove('$_highScoreKeyPrefix${maze.name}');
    }
    await prefs.remove(_allScoresKey);
  }
}
