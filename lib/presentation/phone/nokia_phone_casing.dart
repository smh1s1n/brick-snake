import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game/game_session_state.dart';
import '../../application/providers.dart';
import '../../core/constants/nokia_colors.dart';
import '../../domain/models/direction.dart';
import '../../domain/models/maze.dart';
import '../screen/nokia_lcd_display.dart';
import 'nokia_keypad.dart';

class NokiaPhoneCasing extends ConsumerStatefulWidget {
  const NokiaPhoneCasing({super.key});

  @override
  ConsumerState<NokiaPhoneCasing> createState() => _NokiaPhoneCasingState();
}

class _NokiaPhoneCasingState extends ConsumerState<NokiaPhoneCasing> {
  final FocusNode _focusNode = FocusNode();
  int _menuIndex = 0;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Key Handlers
  void _handleUp() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);

    if (gameState.status == GameStatus.playing) {
      gameController.changeDirection(Direction.up);
    } else if (gameState.status == GameStatus.menu) {
      setState(() {
        if (_menuIndex > 0) _menuIndex--;
      });
      ref.read(audioServiceProvider).playKeyClick();
    } else if (gameState.status == GameStatus.levelSelect) {
      if (settings.level < 9) {
        settingsController.setLevel(settings.level + 1);
        gameController.setLevel(settings.level + 1);
      }
    } else if (gameState.status == GameStatus.mazeSelect) {
      final prevIndex = (settings.mazeType.index - 1 + MazeType.values.length) %
          MazeType.values.length;
      final newMaze = MazeType.values[prevIndex];
      settingsController.setMazeType(newMaze);
      gameController.setMaze(newMaze);
    }
  }

  void _handleDown() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);

    if (gameState.status == GameStatus.playing) {
      gameController.changeDirection(Direction.down);
    } else if (gameState.status == GameStatus.menu) {
      final bool hasActiveGame = gameState.hasStarted && gameState.snake.isAlive;
      final maxItems = hasActiveGame ? 9 : 8;
      setState(() {
        if (_menuIndex < maxItems - 1) _menuIndex++;
      });
      ref.read(audioServiceProvider).playKeyClick();
    } else if (gameState.status == GameStatus.levelSelect) {
      if (settings.level > 1) {
        settingsController.setLevel(settings.level - 1);
        gameController.setLevel(settings.level - 1);
      }
    } else if (gameState.status == GameStatus.mazeSelect) {
      final nextIndex = (settings.mazeType.index + 1) % MazeType.values.length;
      final newMaze = MazeType.values[nextIndex];
      settingsController.setMazeType(newMaze);
      gameController.setMaze(newMaze);
    }
  }

  void _handleLeft() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);

    if (gameState.status == GameStatus.playing) {
      gameController.changeDirection(Direction.left);
    } else if (gameState.status == GameStatus.levelSelect) {
      if (settings.level > 1) {
        settingsController.setLevel(settings.level - 1);
        gameController.setLevel(settings.level - 1);
      }
    } else if (gameState.status == GameStatus.mazeSelect) {
      final prevIndex = (settings.mazeType.index - 1 + MazeType.values.length) %
          MazeType.values.length;
      final newMaze = MazeType.values[prevIndex];
      settingsController.setMazeType(newMaze);
      gameController.setMaze(newMaze);
    }
  }

  void _handleRight() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);

    if (gameState.status == GameStatus.playing) {
      gameController.changeDirection(Direction.right);
    } else if (gameState.status == GameStatus.levelSelect) {
      if (settings.level < 9) {
        settingsController.setLevel(settings.level + 1);
        gameController.setLevel(settings.level + 1);
      }
    } else if (gameState.status == GameStatus.mazeSelect) {
      final nextIndex = (settings.mazeType.index + 1) % MazeType.values.length;
      final newMaze = MazeType.values[nextIndex];
      settingsController.setMazeType(newMaze);
      gameController.setMaze(newMaze);
    }
  }

  void _handleSelect() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    if (gameState.status == GameStatus.playing) {
      gameController.togglePause();
    } else if (gameState.status == GameStatus.paused) {
      gameController.resumeGame();
    } else if (gameState.status == GameStatus.gameOver) {
      gameController.openMenu();
    } else if (gameState.status == GameStatus.mazeSelect ||
        gameState.status == GameStatus.levelSelect ||
        gameState.status == GameStatus.highScores ||
        gameState.status == GameStatus.instructions) {
      gameController.openMenu();
    } else if (gameState.status == GameStatus.menu) {
      final bool hasActiveGame = gameState.hasStarted && gameState.snake.isAlive;
      int idx = _menuIndex;
      if (!hasActiveGame) idx++; // Shift index because "Continue" is omitted

      switch (idx) {
        case 0: // Continue
          gameController.resumeGame();
          break;
        case 1: // New Game
          gameController.startNewGame();
          break;
        case 2: // Mazes
          gameController.openMazeSelect();
          break;
        case 3: // Level
          gameController.openLevelSelect();
          break;
        case 4: // High Scores
          gameController.openHighScores();
          break;
        case 5: // Instructions
          gameController.openInstructions();
          break;
        case 6: // Sound toggle
          settingsController.toggleSound();
          break;
        case 7: // Light toggle
          settingsController.toggleBacklight();
          break;
        case 8: // Theme toggle
          final nextTheme = ScreenTheme.values[
              (settings.theme.index + 1) % ScreenTheme.values.length];
          settingsController.setTheme(nextTheme);
          break;
      }
    }
  }

  void _handleBack() {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);

    if (gameState.status == GameStatus.playing) {
      gameController.pauseGame();
      gameController.openMenu();
    } else {
      gameController.openMenu();
    }
  }

  void _handleNumericKey(String key) {
    final gameState = ref.read(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    if (gameState.status == GameStatus.levelSelect) {
      final int? numVal = int.tryParse(key);
      if (numVal != null && numVal >= 1 && numVal <= 9) {
        settingsController.setLevel(numVal);
        gameController.setLevel(numVal);
      }
    } else if (gameState.status == GameStatus.mazeSelect) {
      final int? numVal = int.tryParse(key);
      if (numVal != null && numVal >= 1 && numVal <= 5) {
        final maze = MazeType.values[numVal - 1];
        settingsController.setMazeType(maze);
        gameController.setMaze(maze);
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW ||
        key == LogicalKeyboardKey.numpad2) {
      _handleUp();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS ||
        key == LogicalKeyboardKey.numpad8) {
      _handleDown();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA ||
        key == LogicalKeyboardKey.numpad4) {
      _handleLeft();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.numpad6) {
      _handleRight();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpad5) {
      _handleSelect();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.keyC) {
      _handleBack();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyL) {
      ref.read(settingsControllerProvider.notifier).toggleBacklight();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyT) {
      setState(() => _torchOn = !_torchOn);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: NokiaColors.casingOuterBlue,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(55),
                bottom: Radius.circular(55),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF496276),
                  Color(0xFF384A5B),
                  Color(0xFF2C3B49),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, 10),
                  blurRadius: 25,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white12,
                  offset: Offset(-2, -2),
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF5A7287),
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                // Top Nokia 1100 LED Flashlight (Clickable!)
                GestureDetector(
                  onTap: () => setState(() => _torchOn = !_torchOn),
                  child: Container(
                    width: 28,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _torchOn ? Colors.white : Colors.black45,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: _torchOn
                          ? [
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                spreadRadius: 3,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _torchOn ? Colors.amberAccent : Colors.grey[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Earpiece Speaker Slit
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 10),

                // NOKIA Logo
                const Text(
                  'NOKIA',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.5,
                    color: Color(0xFFCBD6E2),
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1.5),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // LCD Screen Frame
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: NokiaLcdDisplay(
                    menuSelectedIndex: _menuIndex,
                    onMenuSelectChange: (idx) => setState(() => _menuIndex = idx),
                  ),
                ),

                const SizedBox(height: 16),

                // Nokia 1100 Keypad
                NokiaKeypad(
                  onUp: _handleUp,
                  onDown: _handleDown,
                  onLeft: _handleLeft,
                  onRight: _handleRight,
                  onSelect: _handleSelect,
                  onBack: _handleBack,
                  onNumericKey: _handleNumericKey,
                ),

                const SizedBox(height: 16),

                // Bottom Mic & Pin Holes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
