import 'package:flutter/material.dart';
import '../../domain/models/high_score.dart';
import '../../domain/models/maze.dart';
import '../screen/lcd_font.dart';

class HighScoresView extends StatelessWidget {
  final Map<MazeType, int> recordsByMaze;
  final List<HighScore> allScores;
  final Color pixelColor;
  final Color backgroundColor;

  const HighScoresView({
    super.key,
    required this.recordsByMaze,
    required this.allScores,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _HighScoresPainter(
            recordsByMaze: recordsByMaze,
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _HighScoresPainter extends CustomPainter {
  final Map<MazeType, int> recordsByMaze;
  final Color pixelColor;
  final Color backgroundColor;

  const _HighScoresPainter({
    required this.recordsByMaze,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Title
    const String title = 'HIGH SCORES';
    final double titleW = LcdFont.measureWidth(title, 1.5);
    LcdFont.drawText(
      canvas,
      text: title,
      origin: Offset((size.width - titleW) / 2, 3),
      pixelSize: 1.5,
      color: pixelColor,
    );

    canvas.drawLine(
      const Offset(4, 14),
      Offset(size.width - 4, 14),
      Paint()
        ..color = pixelColor
        ..strokeWidth = 1.0,
    );

    double currentY = 17.0;
    const double rowHeight = 11.0;

    for (final maze in MazeType.values) {
      final score = recordsByMaze[maze] ?? 0;
      final String label = 'M${maze.id}:';
      final String scoreStr = '$score';

      LcdFont.drawText(
        canvas,
        text: label,
        origin: Offset(8, currentY),
        pixelSize: 1.2,
        color: pixelColor,
      );

      final double sW = LcdFont.measureWidth(scoreStr, 1.2);
      LcdFont.drawText(
        canvas,
        text: scoreStr,
        origin: Offset(size.width - sW - 8, currentY),
        pixelSize: 1.2,
        color: pixelColor,
      );

      currentY += rowHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _HighScoresPainter oldDelegate) => true;
}
