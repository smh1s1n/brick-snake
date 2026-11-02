import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/haptic_util.dart';
import '../../domain/models/bonus_food.dart';
import '../../domain/models/direction.dart';
import '../../domain/models/food.dart';
import '../../domain/models/high_score.dart';
import '../../domain/models/maze.dart';
import '../../domain/models/position.dart';
import '../../domain/models/snake.dart';
import '../../domain/repositories/i_high_score_repository.dart';
import '../providers.dart';
import 'game_session_state.dart';

class GameController extends Notifier<GameSessionState> {
  Timer? _gameTimer;
  final List<Direction> _inputQueue = [];
  final Random _random = Random();

  IHighScoreRepository get _highScoreRepository =>
      ref.read(highScoreRepositoryProvider);

  @override
  GameSessionState build() {
    ref.onDispose(() {
      _gameTimer?.cancel();
      _gameTimer = null;
    });

    // Listen to external settings changes without recreating GameController
    ref.listen(settingsControllerProvider, (previous, next) {
      if (previous?.level != next.level) {
        setLevel(next.level);
      }
      if (previous?.mazeType != next.mazeType) {
        setMaze(next.mazeType);
      }
    });

    final settings = ref.read(settingsControllerProvider);
    final initial = _createInitialState(settings);
    _loadHighScore(settings.mazeType);
    return initial;
  }

  static GameSessionState _createInitialState(SettingsState settings) {
    final maze = Maze.create(
      settings.mazeType,
      GameConstants.boardWidth,
      GameConstants.boardHeight,
    );

    final snake = Snake.initial(
      startHead: const Position(
        GameConstants.initialSnakeX,
        GameConstants.initialSnakeY,
      ),
      direction: Direction.right,
      length: GameConstants.initialSnakeLength,
    );

    const food = Food(Position(18, 8));

    return GameSessionState(
      status: GameStatus.menu,
      snake: snake,
      food: food,
      bonusFood: null,
      maze: maze,
      score: 0,
      highScore: 0,
      level: settings.level,
      foodsEaten: 0,
      isNewRecord: false,
      tick: 0,
      hasStarted: false,
    );
  }

  Future<void> _loadHighScore(MazeType mazeType) async {
    final best = await _highScoreRepository.getHighScoreForMaze(mazeType);
    state = state.copyWith(highScore: best);
  }

  // ==========================================
  // Game Loop & Logic
  // ==========================================

  void startNewGame() {
    _gameTimer?.cancel();
    _inputQueue.clear();

    final settings = ref.read(settingsControllerProvider);
    final maze = Maze.create(
      settings.mazeType,
      GameConstants.boardWidth,
      GameConstants.boardHeight,
    );

    final snake = Snake.initial(
      startHead: const Position(
        GameConstants.initialSnakeX,
        GameConstants.initialSnakeY,
      ),
      direction: Direction.right,
      length: GameConstants.initialSnakeLength,
    );

    final food = _generateRandomFood(snake, maze, null);

    state = state.copyWith(
      status: GameStatus.playing,
      snake: snake,
      food: food,
      bonusFood: () => null,
      maze: maze,
      score: 0,
      level: settings.level,
      foodsEaten: 0,
      isNewRecord: false,
      crashTick: 0,
      tick: state.tick + 1,
      hasStarted: true,
    );

    _startTimer();
    _playKeySound();
  }

  void resumeGame() {
    if (state.status == GameStatus.paused || state.status == GameStatus.menu) {
      if (state.snake.isAlive && state.hasStarted) {
        state = state.copyWith(
          status: GameStatus.playing,
          tick: state.tick + 1,
        );
        _startTimer();
        _playKeySound();
      } else {
        startNewGame();
      }
    }
  }

  void pauseGame() {
    if (state.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _gameTimer = null;
      state = state.copyWith(
        status: GameStatus.paused,
        tick: state.tick + 1,
      );
      _playKeySound();
    }
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      pauseGame();
    } else if (state.status == GameStatus.paused) {
      resumeGame();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    final int delayMs = GameConstants.speedMilliseconds[state.level - 1];
    _gameTimer = Timer.periodic(
      Duration(milliseconds: delayMs),
      (_) => _onTick(),
    );
  }

  void _onTick() {
    if (state.status != GameStatus.playing) {
      _gameTimer?.cancel();
      _gameTimer = null;
      return;
    }

    // Process queued direction
    Direction currentDir = state.snake.direction;
    while (_inputQueue.isNotEmpty) {
      final nextDir = _inputQueue.removeAt(0);
      if (!nextDir.isOpposite(currentDir) && nextDir != currentDir) {
        currentDir = nextDir;
        break;
      }
    }

    Position newHead = state.snake.head + currentDir.delta;

    // Boundary wrapping or solid wall collision
    if (state.maze.isWrapped) {
      newHead = newHead.wrap(
        GameConstants.boardWidth,
        GameConstants.boardHeight,
      );
    } else {
      if (newHead.x < 0 ||
          newHead.x >= GameConstants.boardWidth ||
          newHead.y < 0 ||
          newHead.y >= GameConstants.boardHeight) {
        _handleCrash();
        return;
      }
    }

    // Check collision with maze walls
    if (state.maze.hasWall(newHead)) {
      _handleCrash();
      return;
    }

    final bool eatsFood = newHead == state.food.position;

    // Check collision with snake's own body
    final bodyToCheck = eatsFood
        ? state.snake.body
        : state.snake.body.sublist(0, state.snake.body.length - 1);
    if (bodyToCheck.contains(newHead)) {
      _handleCrash();
      return;
    }

    // Bonus food handling
    BonusFood? updatedBonus = state.bonusFood;
    int pointsEarned = 0;

    final audio = ref.read(audioServiceProvider);
    final settings = ref.read(settingsControllerProvider);

    if (updatedBonus != null) {
      if (newHead == updatedBonus.position) {
        pointsEarned += GameConstants.bonusFoodScore(
          state.level,
          updatedBonus.remainingTicks,
        );
        updatedBonus = null;
        audio.playEatBonus();
        if (settings.vibrationEnabled) HapticUtil.mediumClick();
      } else {
        final ticked = updatedBonus.tick();
        updatedBonus = ticked.isExpired ? null : ticked;
      }
    }

    int newFoodsEaten = state.foodsEaten;
    Food newFood = state.food;

    if (eatsFood) {
      pointsEarned += GameConstants.baseFoodScore(state.level);
      newFoodsEaten++;
      audio.playEatFood();
      if (settings.vibrationEnabled) HapticUtil.lightClick();

      // Spawn bonus food every 5 foods
      if (newFoodsEaten % GameConstants.foodsPerBonus == 0 &&
          updatedBonus == null) {
        updatedBonus = _generateBonusFood(state.snake, state.maze, state.food);
        audio.playBonusSpawn();
      }
    }

    final newScore = state.score + pointsEarned;
    final newSnake = state.snake.move(
      newHead: newHead,
      newDirection: currentDir,
      grow: eatsFood,
    );

    if (eatsFood) {
      newFood = _generateRandomFood(newSnake, state.maze, updatedBonus);
    }

    // Emits new state with incremented tick counter ensuring instant UI repaint
    state = state.copyWith(
      snake: newSnake,
      food: newFood,
      bonusFood: () => updatedBonus,
      score: newScore,
      foodsEaten: newFoodsEaten,
      tick: state.tick + 1,
    );
  }

  void _handleCrash() async {
    _gameTimer?.cancel();
    _gameTimer = null;

    final audio = ref.read(audioServiceProvider);
    final settings = ref.read(settingsControllerProvider);

    audio.playCrash();
    if (settings.vibrationEnabled) HapticUtil.crashVibrate();

    final isRecord = state.score > state.highScore;
    if (isRecord) {
      audio.playHighScore();
      await _highScoreRepository.saveHighScore(
        HighScore(
          score: state.score,
          level: state.level,
          mazeType: state.maze.type,
          date: DateTime.now(),
        ),
      );
    }

    state = state.copyWith(
      status: GameStatus.gameOver,
      snake: state.snake.die(),
      isNewRecord: isRecord,
      highScore: isRecord ? state.score : state.highScore,
      tick: state.tick + 1,
      hasStarted: false,
    );
  }

  // ==========================================
  // Inputs & Direction Queueing
  // ==========================================

  void changeDirection(Direction dir) {
    if (state.status != GameStatus.playing) return;

    final Direction lastQueued =
        _inputQueue.isNotEmpty ? _inputQueue.last : state.snake.direction;

    if (!dir.isOpposite(lastQueued) && dir != lastQueued) {
      if (_inputQueue.length < 2) {
        _inputQueue.add(dir);
      }
    }
  }

  // ==========================================
  // Menu & Navigation
  // ==========================================

  void openMenu() {
    _gameTimer?.cancel();
    _gameTimer = null;
    state = state.copyWith(
      status: GameStatus.menu,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void openMazeSelect() {
    _gameTimer?.cancel();
    _gameTimer = null;
    state = state.copyWith(
      status: GameStatus.mazeSelect,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void openLevelSelect() {
    _gameTimer?.cancel();
    _gameTimer = null;
    state = state.copyWith(
      status: GameStatus.levelSelect,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void openHighScores() {
    _gameTimer?.cancel();
    _gameTimer = null;
    state = state.copyWith(
      status: GameStatus.highScores,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void openInstructions() {
    _gameTimer?.cancel();
    _gameTimer = null;
    state = state.copyWith(
      status: GameStatus.instructions,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void setMaze(MazeType mazeType) async {
    final maze = Maze.create(
      mazeType,
      GameConstants.boardWidth,
      GameConstants.boardHeight,
    );
    final best = await _highScoreRepository.getHighScoreForMaze(mazeType);
    state = state.copyWith(
      maze: maze,
      highScore: best,
      tick: state.tick + 1,
    );
    _playKeySound();
  }

  void setLevel(int level) {
    state = state.copyWith(
      level: level,
      tick: state.tick + 1,
    );
    if (state.status == GameStatus.playing) {
      _startTimer();
    }
    _playKeySound();
  }

  void _playKeySound() {
    final audio = ref.read(audioServiceProvider);
    final settings = ref.read(settingsControllerProvider);
    audio.playKeyClick();
    if (settings.vibrationEnabled) HapticUtil.lightClick();
  }

  // ==========================================
  // Food Generation Helpers
  // ==========================================

  Food _generateRandomFood(Snake snake, Maze maze, BonusFood? bonus) {
    final List<Position> emptySlots = [];
    for (int x = 0; x < GameConstants.boardWidth; x++) {
      for (int y = 0; y < GameConstants.boardHeight; y++) {
        final pos = Position(x, y);
        if (!snake.occupies(pos) &&
            !maze.hasWall(pos) &&
            (bonus == null || bonus.position != pos)) {
          emptySlots.add(pos);
        }
      }
    }

    if (emptySlots.isEmpty) {
      return const Food(Position(0, 0));
    }
    return Food(emptySlots[_random.nextInt(emptySlots.length)]);
  }

  BonusFood _generateBonusFood(Snake snake, Maze maze, Food currentFood) {
    final List<Position> emptySlots = [];
    for (int x = 1; x < GameConstants.boardWidth - 1; x++) {
      for (int y = 1; y < GameConstants.boardHeight - 1; y++) {
        final pos = Position(x, y);
        if (!snake.occupies(pos) &&
            !maze.hasWall(pos) &&
            currentFood.position != pos) {
          emptySlots.add(pos);
        }
      }
    }

    final Position bonusPos = emptySlots.isNotEmpty
        ? emptySlots[_random.nextInt(emptySlots.length)]
        : const Position(10, 8);

    final bonusTypes = [BonusType.insect, BonusType.spider, BonusType.fly];
    final selectedType = bonusTypes[_random.nextInt(bonusTypes.length)];

    return BonusFood(
      position: bonusPos,
      remainingTicks: GameConstants.bonusLifetimeTicks,
      maxTicks: GameConstants.bonusLifetimeTicks,
      type: selectedType,
    );
  }
}
