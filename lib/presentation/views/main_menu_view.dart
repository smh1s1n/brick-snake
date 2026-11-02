import 'package:flutter/material.dart';
import '../../core/constants/nokia_colors.dart';
import '../screen/lcd_font.dart';

class MainMenuView extends StatelessWidget {
  final int selectedIndex;
  final bool hasActiveGame;
  final bool soundEnabled;
  final bool backlightOn;
  final ScreenTheme theme;
  final Color pixelColor;
  final Color backgroundColor;

  const MainMenuView({
    super.key,
    required this.selectedIndex,
    required this.hasActiveGame,
    required this.soundEnabled,
    required this.backlightOn,
    required this.theme,
    required this.pixelColor,
    required this.backgroundColor,
  });

  List<String> get menuItems => [
        if (hasActiveGame) 'CONTINUE',
        'NEW GAME',
        'MAZES',
        'LEVEL',
        'HIGH SCORES',
        'INSTRUCTIONS',
        'SOUND: ${soundEnabled ? "ON" : "OFF"}',
        'LIGHT: ${backlightOn ? "ON" : "OFF"}',
        'THEME: ${theme.displayName.toUpperCase()}',
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MainMenuPainter(
            items: menuItems,
            selectedIndex: selectedIndex.clamp(0, menuItems.length - 1),
            pixelColor: pixelColor,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class _MainMenuPainter extends CustomPainter {
  final List<String> items;
  final int selectedIndex;
  final Color pixelColor;
  final Color backgroundColor;

  const _MainMenuPainter({
    required this.items,
    required this.selectedIndex,
    required this.pixelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Header / Title: "SNAKE 1100"
    final double titleW = LcdFont.measureWidth('SNAKE 1100', 1.8);
    final double titleX = (size.width - titleW) / 2;

    LcdFont.drawText(
      canvas,
      text: 'SNAKE 1100',
      origin: Offset(titleX, 2),
      pixelSize: 1.8,
      color: pixelColor,
    );

    // Separator line
    canvas.drawLine(
      const Offset(4, 16),
      Offset(size.width - 4, 16),
      Paint()
        ..color = pixelColor
        ..strokeWidth = 1.0,
    );

    // 2. Visible items window (Nokia scrolled 3-4 items at a time)
    const int maxVisible = 4;
    int startIndex = 0;
    if (selectedIndex >= maxVisible) {
      startIndex = selectedIndex - maxVisible + 1;
    }
    final int endIndex = (startIndex + maxVisible).clamp(0, items.length);

    double currentY = 20.0;
    const double itemHeight = 12.0;

    for (int i = startIndex; i < endIndex; i++) {
      final bool isSelected = i == selectedIndex;
      final String text = '${i + 1}. ${items[i]}';

      if (isSelected) {
        // Inverted black bar
        canvas.drawRect(
          Rect.fromLTWH(2, currentY - 1, size.width - 4, itemHeight),
          Paint()
            ..color = pixelColor
            ..style = PaintingStyle.fill,
        );

        // Light text on dark bar
        LcdFont.drawText(
          canvas,
          text: text,
          origin: Offset(6, currentY + 1),
          pixelSize: 1.5,
          color: backgroundColor,
        );
      } else {
        // Normal dark text
        LcdFont.drawText(
          canvas,
          text: text,
          origin: Offset(6, currentY + 1),
          pixelSize: 1.5,
          color: pixelColor,
        );
      }

      currentY += itemHeight + 2;
    }

    // Scroll indicators if items exist above or below
    if (startIndex > 0) {
      // Small up arrow
      LcdFont.drawText(
        canvas,
        text: '^',
        origin: Offset(size.width - 10, 18),
        pixelSize: 1.0,
        color: pixelColor,
      );
    }
    if (endIndex < items.length) {
      // Small down indicator
      canvas.drawRect(
        Rect.fromLTWH(size.width - 10, size.height - 6, 4, 2),
        Paint()
          ..color = pixelColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MainMenuPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.items.length != items.length ||
      oldDelegate.pixelColor != pixelColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
