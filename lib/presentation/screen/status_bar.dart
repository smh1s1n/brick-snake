import 'package:flutter/material.dart';

class NokiaStatusBarPainter extends CustomPainter {
  final Color pixelColor;
  final bool soundEnabled;
  final int signalLevel; // 1 to 4
  final int batteryLevel; // 1 to 4

  const NokiaStatusBarPainter({
    required this.pixelColor,
    required this.soundEnabled,
    this.signalLevel = 4,
    this.batteryLevel = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pixelColor
      ..style = PaintingStyle.fill;

    const double p = 2.0; // pixel unit size

    // 1. Draw Signal Bars on Left
    // Antenna symbol
    canvas.drawRect(const Rect.fromLTWH(4, 2, p, p * 4), paint);
    canvas.drawRect(const Rect.fromLTWH(2, 2, p * 3, p), paint);

    // 4 ascending signal bars
    for (int i = 0; i < 4; i++) {
      if (i < signalLevel) {
        final double barHeight = (i + 1) * (p * 1.5);
        canvas.drawRect(
          Rect.fromLTWH(12 + (i * (p * 2)), 10 - barHeight, p, barHeight),
          paint,
        );
      }
    }

    // 2. Center: Sound or Vibration status icon
    if (!soundEnabled) {
      // Small musical note with a slash or cross
      canvas.drawRect(Rect.fromLTWH(size.width / 2 - 4, 3, 2, 6), paint);
      canvas.drawRect(Rect.fromLTWH(size.width / 2 - 6, 7, 3, 2), paint);
      // Slash
      canvas.drawRect(Rect.fromLTWH(size.width / 2 - 6, 2, 8, 2), paint);
    }

    // 3. Draw Battery on Right
    final double bX = size.width - 26;
    // Battery terminal nipple
    canvas.drawRect(Rect.fromLTWH(bX - 2, 4, 2, 4), paint);
    // Battery outer casing
    canvas.drawRect(Rect.fromLTWH(bX, 2, 20, 8), Paint()
      ..color = pixelColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // Battery fill bars
    for (int i = 0; i < 4; i++) {
      if (i < batteryLevel) {
        canvas.drawRect(
          Rect.fromLTWH(bX + 2 + (i * 4.2), 3.5, 3, 5),
          paint,
        );
      }
    }

    // Bottom separator line
    final linePaint = Paint()
      ..color = pixelColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant NokiaStatusBarPainter oldDelegate) =>
      oldDelegate.pixelColor != pixelColor ||
      oldDelegate.soundEnabled != soundEnabled ||
      oldDelegate.signalLevel != signalLevel ||
      oldDelegate.batteryLevel != batteryLevel;
}
