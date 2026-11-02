import '../models/high_score.dart';
import '../models/maze.dart';

abstract class IHighScoreRepository {
  Future<int> getHighScoreForMaze(MazeType mazeType);
  Future<List<HighScore>> getAllHighScores();
  Future<bool> saveHighScore(HighScore highScore);
  Future<void> clearAllScores();
}
