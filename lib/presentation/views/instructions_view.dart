import 'package:flutter/material.dart';
import '../screen/lcd_font.dart';

class InstructionsView extends StatelessWidget {
  final int pageIndex;
  final Color pixelColor;
  final Color backgroundColor;

  const InstructionsView({
    super.key,
    this.pageIndex = 0,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _InstructionsPainter(
            page: pageIndex,
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _InstructionsPainter extends CustomPainter {
  final int page;
  final Color pixelColor;
  final Color backgroundColor;

  const _InstructionsPainter({
    required this.page,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const String title = 'HOW TO PLAY';
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

    final List<String> lines = [
      '2/UP: MOVE UP',
      '8/DOWN: MOVE DOWN',
      '4/LEFT: MOVE LEFT',
      '6/RIGHT: MOVE RIGHT',
      'EAT FOOD TO GROW',
      'CATCH BUGS FOR BONUS',
    ];

    double y = 18.0;
    for (final line in lines) {
      LcdFont.drawText(
        canvas,
        text: line,
        origin: Offset(6, y),
        pixelSize: 1.0,
        color: pixelColor,
      );
      y += 9.0;
    }
  }

  @override
  bool shouldRepaint(covariant _InstructionsPainter oldDelegate) => false;
}
