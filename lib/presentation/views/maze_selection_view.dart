import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/models/maze.dart';
import '../screen/lcd_font.dart';

class MazeSelectionView extends StatelessWidget {
  final MazeType currentMazeType;
  final int highScore;
  final Color pixelColor;
  final Color backgroundColor;

  const MazeSelectionView({
    super.key,
    required this.currentMazeType,
    required this.highScore,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MazeSelectionPainter(
            mazeType: currentMazeType,
            highScore: highScore,
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _MazeSelectionPainter extends CustomPainter {
  final MazeType mazeType;
  final int highScore;
  final Color pixelColor;
  final Color backgroundColor;

  const _MazeSelectionPainter({
    required this.mazeType,
    required this.highScore,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maze = Maze.create(
      mazeType,
      GameConstants.boardWidth,
      GameConstants.boardHeight,
    );

    // Title: MAZE X/5
    final String title = 'MAZE ${mazeType.id}/5';
    final double titleW = LcdFont.measureWidth(title, 1.5);
    LcdFont.drawText(
      canvas,
      text: title,
      origin: Offset((size.width - titleW) / 2, 2),
      pixelSize: 1.5,
      color: pixelColor,
    );

    // Subtitle / Name: e.g. "SOLID BOX"
    final double nameW = LcdFont.measureWidth(mazeType.title, 1.2);
    LcdFont.drawText(
      canvas,
      text: mazeType.title,
      origin: Offset((size.width - nameW) / 2, 11),
      pixelSize: 1.2,
      color: pixelColor,
    );

    // Miniature Board Preview
    const double previewW = 96.0;
    const double previewH = 40.0;
    final double px = (size.width - previewW) / 2;
    const double py = 21.0;

    // Draw preview border
    canvas.drawRect(
      Rect.fromLTWH(px, py, previewW, previewH),
      Paint()
        ..color = pixelColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final double cellW = previewW / GameConstants.boardWidth;
    final double cellH = previewH / GameConstants.boardHeight;

    final wallPaint = Paint()
      ..color = pixelColor
      ..style = PaintingStyle.fill;

    for (final wall in maze.walls) {
      canvas.drawRect(
        Rect.fromLTWH(
          px + (wall.x * cellW),
          py + (wall.y * cellH),
          cellW.clamp(1.0, 10.0),
          cellH.clamp(1.0, 10.0),
        ),
        wallPaint,
      );
    }

    // High Score for this maze
    final String hsText = 'RECORD: $highScore';
    final double hsW = LcdFont.measureWidth(hsText, 1.2);
    LcdFont.drawText(
      canvas,
      text: hsText,
      origin: Offset((size.width - hsW) / 2, 64),
      pixelSize: 1.2,
      color: pixelColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MazeSelectionPainter oldDelegate) =>
      oldDelegate.mazeType != mazeType ||
      oldDelegate.highScore != highScore ||
      oldDelegate.pixelColor != pixelColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
