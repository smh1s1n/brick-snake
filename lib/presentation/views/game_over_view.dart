import 'package:flutter/material.dart';
import '../screen/lcd_font.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isNewRecord;
  final Color pixelColor;
  final Color backgroundColor;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GameOverPainter(
            score: score,
            highScore: highScore,
            isNewRecord: isNewRecord,
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _GameOverPainter extends CustomPainter {
  final int score;
  final int highScore;
  final bool isNewRecord;
  final Color pixelColor;
  final Color backgroundColor;

  const _GameOverPainter({
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Semi-translucent or solid dialog box in center
    const double boxW = 120.0;
    const double boxH = 54.0;
    final double bx = (size.width - boxW) / 2;
    final double by = (size.height - boxH) / 2;

    // Fill dialog with LCD background
    canvas.drawRect(
      Rect.fromLTWH(bx, by, boxW, boxH),
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    // Thick black pixel border
    canvas.drawRect(
      Rect.fromLTWH(bx, by, boxW, boxH),
      Paint()
        ..color = pixelColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // GAME OVER
    const String title = 'GAME OVER';
    final double titleW = LcdFont.measureWidth(title, 1.8);
    LcdFont.drawText(
      canvas,
      text: title,
      origin: Offset((size.width - titleW) / 2, by + 5),
      pixelSize: 1.8,
      color: pixelColor,
    );

    // SCORE
    final String scoreStr = isNewRecord ? 'RECORD! $score' : 'SCORE: $score';
    final double scoreW = LcdFont.measureWidth(scoreStr, 1.4);
    LcdFont.drawText(
      canvas,
      text: scoreStr,
      origin: Offset((size.width - scoreW) / 2, by + 22),
      pixelSize: 1.4,
      color: pixelColor,
    );

    // Prompt: PRESS OK
    const String prompt = 'PRESS 5 / OK';
    final double promptW = LcdFont.measureWidth(prompt, 1.1);
    LcdFont.drawText(
      canvas,
      text: prompt,
      origin: Offset((size.width - promptW) / 2, by + 38),
      pixelSize: 1.1,
      color: pixelColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GameOverPainter oldDelegate) => true;
}
