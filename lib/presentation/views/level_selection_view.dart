import 'package:flutter/material.dart';
import '../screen/lcd_font.dart';

class LevelSelectionView extends StatelessWidget {
  final int currentLevel;
  final Color pixelColor;
  final Color backgroundColor;

  const LevelSelectionView({
    super.key,
    required this.currentLevel,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LevelSelectionPainter(
            currentLevel: currentLevel,
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _LevelSelectionPainter extends CustomPainter {
  final int currentLevel;
  final Color pixelColor;
  final Color backgroundColor;

  const _LevelSelectionPainter({
    required this.currentLevel,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Title
    const String title = 'GAME SPEED';
    final double titleW = LcdFont.measureWidth(title, 1.5);
    LcdFont.drawText(
      canvas,
      text: title,
      origin: Offset((size.width - titleW) / 2, 6),
      pixelSize: 1.5,
      color: pixelColor,
    );

    // Big Level Number
    final String lvlStr = '$currentLevel';
    final double numW = LcdFont.measureWidth(lvlStr, 4.0);
    LcdFont.drawText(
      canvas,
      text: lvlStr,
      origin: Offset((size.width - numW) / 2, 22),
      pixelSize: 4.0,
      color: pixelColor,
    );

    // 9-segment Speed Gauge Bar
    const double barTotalW = 108.0;
    final double startX = (size.width - barTotalW) / 2;
    const double barY = 50.0;
    const double segW = 10.0;
    const double segH = 8.0;
    const double segGap = 2.0;

    for (int i = 1; i <= 9; i++) {
      final double sx = startX + ((i - 1) * (segW + segGap));
      if (i <= currentLevel) {
        // Filled segment
        canvas.drawRect(
          Rect.fromLTWH(sx, barY, segW, segH),
          Paint()
            ..color = pixelColor
            ..style = PaintingStyle.fill,
        );
      } else {
        // Empty frame
        canvas.drawRect(
          Rect.fromLTWH(sx, barY, segW, segH),
          Paint()
            ..color = pixelColor.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    // Helper text
    const String sub = '1=SLOW  9=FAST';
    final double subW = LcdFont.measureWidth(sub, 1.2);
    LcdFont.drawText(
      canvas,
      text: sub,
      origin: Offset((size.width - subW) / 2, 64),
      pixelSize: 1.2,
      color: pixelColor,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelSelectionPainter oldDelegate) =>
      oldDelegate.currentLevel != currentLevel ||
      oldDelegate.pixelColor != pixelColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
