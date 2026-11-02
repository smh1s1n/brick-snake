import '../../domain/models/bonus_food.dart';
import '../../domain/models/food.dart';
import '../../domain/models/maze.dart';
import '../../domain/models/snake.dart';

enum GameStatus {
  menu,
  playing,
  paused,
  gameOver,
  mazeSelect,
  levelSelect,
  highScores,
  instructions,
}

class GameSessionState {
  final GameStatus status;
  final Snake snake;
  final Food food;
  final BonusFood? bonusFood;
  final Maze maze;
  final int score;
  final int highScore;
  final int level;
  final int foodsEaten;
  final bool isNewRecord;
  final int crashTick;
  final int tick; // Monotonically increasing tick counter ensuring Riverpod triggers on every frame
  final bool hasStarted; // False on cold boot until player starts a game

  const GameSessionState({
    required this.status,
    required this.snake,
    required this.food,
    this.bonusFood,
    required this.maze,
    required this.score,
    required this.highScore,
    required this.level,
    required this.foodsEaten,
    required this.isNewRecord,
    this.crashTick = 0,
    this.tick = 0,
    this.hasStarted = false,
  });

  GameSessionState copyWith({
    GameStatus? status,
    Snake? snake,
    Food? food,
    BonusFood? Function()? bonusFood,
    Maze? maze,
    int? score,
    int? highScore,
    int? level,
    int? foodsEaten,
    bool? isNewRecord,
    int? crashTick,
    int? tick,
    bool? hasStarted,
  }) {
    return GameSessionState(
      status: status ?? this.status,
      snake: snake ?? this.snake,
      food: food ?? this.food,
      bonusFood: bonusFood != null ? bonusFood() : this.bonusFood,
      maze: maze ?? this.maze,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      level: level ?? this.level,
      foodsEaten: foodsEaten ?? this.foodsEaten,
      isNewRecord: isNewRecord ?? this.isNewRecord,
      crashTick: crashTick ?? this.crashTick,
      tick: tick ?? this.tick,
      hasStarted: hasStarted ?? this.hasStarted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSessionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          tick == other.tick &&
          snake == other.snake &&
          food == other.food &&
          bonusFood == other.bonusFood &&
          maze == other.maze &&
          score == other.score &&
          highScore == other.highScore &&
          level == other.level &&
          foodsEaten == other.foodsEaten &&
          isNewRecord == other.isNewRecord &&
          crashTick == other.crashTick &&
          hasStarted == other.hasStarted;

  @override
  int get hashCode => Object.hash(
        status,
        tick,
        snake,
        food,
        bonusFood,
        maze,
        score,
        highScore,
        level,
        foodsEaten,
        isNewRecord,
        crashTick,
        hasStarted,
      );
}
