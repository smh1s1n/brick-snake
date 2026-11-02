import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game/game_session_state.dart';
import '../../application/providers.dart';
import '../../core/constants/nokia_colors.dart';
import '../../domain/models/direction.dart';
import '../../domain/models/maze.dart';
import '../views/game_over_view.dart';
import '../views/high_scores_view.dart';
import '../views/instructions_view.dart';
import '../views/level_selection_view.dart';
import '../views/main_menu_view.dart';
import '../views/maze_selection_view.dart';
import 'snake_board_painter.dart';
import 'status_bar.dart';

class NokiaLcdDisplay extends ConsumerStatefulWidget {
  final int menuSelectedIndex;
  final Function(int) onMenuSelectChange;

  const NokiaLcdDisplay({
    super.key,
    required this.menuSelectedIndex,
    required this.onMenuSelectChange,
  });

  @override
  ConsumerState<NokiaLcdDisplay> createState() => _NokiaLcdDisplayState();
}

class _NokiaLcdDisplayState extends ConsumerState<NokiaLcdDisplay> {
  Offset? _panStart;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);

    final Color bgColor = settings.backlightOn
        ? settings.theme.backgroundColor
        : NokiaColors.lcdScreenBgOff;
    final Color pixelColor = settings.theme.pixelColor;

    return GestureDetector(
      onPanStart: (details) {
        _panStart = details.localPosition;
      },
      onPanEnd: (details) {
        _panStart = null;
      },
      onPanUpdate: (details) {
        if (_panStart == null) return;
        final dx = details.localPosition.dx - _panStart!.dx;
        final dy = details.localPosition.dy - _panStart!.dy;
        const double threshold = 25.0;

        if (dx.abs() > threshold || dy.abs() > threshold) {
          if (dx.abs() > dy.abs()) {
            if (dx > 0) {
              gameController.changeDirection(Direction.right);
            } else {
              gameController.changeDirection(Direction.left);
            }
          } else {
            if (dy > 0) {
              gameController.changeDirection(Direction.down);
            } else {
              gameController.changeDirection(Direction.up);
            }
          }
          _panStart = details.localPosition;
        }
      },
      child: AspectRatio(
        // Classic Nokia 1100 display aspect ratio ~96x65 (~1.48:1)
        aspectRatio: 96 / 65,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: NokiaColors.casingBezel,
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, -1),
                blurRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Subtle Dot-Matrix LCD Background Mesh Shader/Painter
                const CustomPaint(
                  painter: _LcdGridOverlayPainter(),
                ),

                // 2. Main Content Area
                Column(
                  children: [
                    // Top Nokia Status Bar
                    SizedBox(
                      height: 12,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: NokiaStatusBarPainter(
                          pixelColor: pixelColor,
                          soundEnabled: settings.soundEnabled,
                        ),
                      ),
                    ),

                    // Active Screen Body
                    Expanded(
                      child: _buildActiveScreen(
                        gameState,
                        settings,
                        gameController,
                        pixelColor,
                        bgColor,
                      ),
                    ),
                  ],
                ),

                // 3. Game Over Overlay (if died)
                if (gameState.status == GameStatus.gameOver)
                  GameOverOverlay(
                    score: gameState.score,
                    highScore: gameState.highScore,
                    isNewRecord: gameState.isNewRecord,
                    pixelColor: pixelColor,
                    backgroundColor: bgColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveScreen(
    GameSessionState gameState,
    SettingsState settings,
    dynamic gameController,
    Color pixelColor,
    Color bgColor,
  ) {
    switch (gameState.status) {
      case GameStatus.menu:
        return MainMenuView(
          selectedIndex: widget.menuSelectedIndex,
          hasActiveGame: gameState.hasStarted && gameState.snake.isAlive,
          soundEnabled: settings.soundEnabled,
          backlightOn: settings.backlightOn,
          theme: settings.theme,
          pixelColor: pixelColor,
          backgroundColor: bgColor,
        );

      case GameStatus.playing:
      case GameStatus.paused:
      case GameStatus.gameOver:
        return CustomPaint(
          size: Size.infinite,
          painter: SnakeBoardPainter(
            snake: gameState.snake,
            food: gameState.food,
            bonusFood: gameState.bonusFood,
            maze: gameState.maze,
            score: gameState.score,
            level: gameState.level,
            pixelColor: pixelColor,
            backgroundColor: bgColor,
            isGameOver: gameState.status == GameStatus.gameOver,
          ),
        );

      case GameStatus.mazeSelect:
        return MazeSelectionView(
          currentMazeType: settings.mazeType,
          highScore: gameState.highScore,
          pixelColor: pixelColor,
          backgroundColor: bgColor,
        );

      case GameStatus.levelSelect:
        return LevelSelectionView(
          currentLevel: settings.level,
          pixelColor: pixelColor,
          backgroundColor: bgColor,
        );

      case GameStatus.highScores:
        return HighScoresView(
          recordsByMaze: {
            for (final m in MazeType.values)
              m: (m == gameState.maze.type ? gameState.highScore : 0),
          },
          allScores: const [],
          pixelColor: pixelColor,
          backgroundColor: bgColor,
        );

      case GameStatus.instructions:
        return InstructionsView(
          pixelColor: pixelColor,
          backgroundColor: bgColor,
        );
    }
  }
}

class _LcdGridOverlayPainter extends CustomPainter {
  const _LcdGridOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle pixel mesh
    final paint = Paint()
      ..color = const Color(0x0A000000)
      ..strokeWidth = 0.5;

    const double step = 3.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
