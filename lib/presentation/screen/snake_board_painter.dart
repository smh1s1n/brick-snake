import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/models/bonus_food.dart';
import '../../domain/models/direction.dart';
import '../../domain/models/food.dart';
import '../../domain/models/maze.dart';
import '../../domain/models/position.dart';
import '../../domain/models/snake.dart';
import 'lcd_font.dart';

class SnakeBoardPainter extends CustomPainter {
  final Snake snake;
  final Food food;
  final BonusFood? bonusFood;
  final Maze maze;
  final int score;
  final int level;
  final Color pixelColor;
  final Color backgroundColor;
  final bool isGameOver;

  const SnakeBoardPainter({
    required this.snake,
    required this.food,
    this.bonusFood,
    required this.maze,
    required this.score,
    required this.level,
    required this.pixelColor,
    required this.backgroundColor,
    this.isGameOver = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Top HUD area height
    const double hudHeight = 14.0;
    final double boardHeight = size.height - hudHeight;

    // Calculate grid cell dimensions
    final double cellW = size.width / GameConstants.boardWidth;
    final double cellH = boardHeight / GameConstants.boardHeight;

    final pixelPaint = Paint()
      ..color = pixelColor
      ..style = PaintingStyle.fill;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Draw HUD: Score and Level in LCD bitmap font
    final String scoreStr = '$score';
    final String lvlStr = 'L:$level';

    LcdFont.drawText(
      canvas,
      text: lvlStr,
      origin: const Offset(4, 3),
      pixelSize: 1.5,
      color: pixelColor,
    );

    final double scoreW = LcdFont.measureWidth(scoreStr, 1.5);
    LcdFont.drawText(
      canvas,
      text: scoreStr,
      origin: Offset(size.width - scoreW - 4, 3),
      pixelSize: 1.5,
      color: pixelColor,
    );

    // Separator under HUD
    canvas.drawLine(
      const Offset(0, hudHeight - 1),
      Offset(size.width, hudHeight - 1),
      Paint()
        ..color = pixelColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.0,
    );

    // If bonus food is active, draw bonus timer progress bar across top of play area
    if (bonusFood != null) {
      final double barWidth = size.width * bonusFood!.progress;
      canvas.drawRect(
        Rect.fromLTWH(0, hudHeight, size.width, 2),
        Paint()
          ..color = pixelColor.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, hudHeight, barWidth, 2),
        pixelPaint,
      );
    }

    // 1. Draw Maze Walls
    for (final wall in maze.walls) {
      final double wx = wall.x * cellW;
      final double wy = hudHeight + (wall.y * cellH);
      // Solid block with classic Nokia brick texture
      canvas.drawRect(
        Rect.fromLTWH(wx + 0.5, wy + 0.5, cellW - 1, cellH - 1),
        pixelPaint,
      );
      // Subtle 1-pixel inner relief
      canvas.drawRect(
        Rect.fromLTWH(wx + 1.5, wy + 1.5, cellW - 3, cellH - 3),
        Paint()
          ..color = backgroundColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // 2. Draw Food (Classic 3x3 pixel apple with stem)
    final double fx = food.position.x * cellW;
    final double fy = hudHeight + (food.position.y * cellH);
    _drawFood(canvas, Offset(fx, fy), cellW, cellH, pixelPaint);

    // 3. Draw Bonus Food (Insect / Bug) if active
    if (bonusFood != null) {
      final double bx = bonusFood!.position.x * cellW;
      final double by = hudHeight + (bonusFood!.position.y * cellH);
      _drawInsect(canvas, Offset(bx, by), cellW, cellH, pixelPaint, bgPaint);
    }

    // 4. Draw Snake Body & Head
    final List<Position> body = snake.body;
    for (int i = 0; i < body.length; i++) {
      final Position seg = body[i];
      final double sx = seg.x * cellW;
      final double sy = hudHeight + (seg.y * cellH);

      if (i == 0) {
        // Snake Head
        _drawSnakeHead(
          canvas,
          Offset(sx, sy),
          cellW,
          cellH,
          snake.direction,
          pixelPaint,
          bgPaint,
          isDead: isGameOver || !snake.isAlive,
        );
      } else {
        // Snake Body Segment
        final double pad = 0.5;
        canvas.drawRect(
          Rect.fromLTWH(sx + pad, sy + pad, cellW - (pad * 2), cellH - (pad * 2)),
          pixelPaint,
        );
        // Small inner core dot for authentic Nokia snake scale look
        if (cellW >= 6 && cellH >= 6) {
          canvas.drawRect(
            Rect.fromLTWH(sx + 2, sy + 2, cellW - 4, cellH - 4),
            Paint()
              ..color = backgroundColor.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  void _drawFood(Canvas canvas, Offset origin, double cw, double ch, Paint paint) {
    // 3x3 apple shape
    final double midX = origin.dx + (cw / 2);
    final double midY = origin.dy + (ch / 2);
    final double p = cw / 4;

    // Food body
    canvas.drawRect(Rect.fromLTWH(midX - p, midY - (p * 0.5), p * 2, p * 2), paint);
    // Stem
    canvas.drawRect(Rect.fromLTWH(midX - (p * 0.4), midY - (p * 1.5), p * 0.8, p), paint);
  }

  void _drawInsect(
    Canvas canvas,
    Offset origin,
    double cw,
    double ch,
    Paint darkPaint,
    Paint lightPaint,
  ) {
    final double midX = origin.dx + (cw / 2);
    final double midY = origin.dy + (ch / 2);
    final double p = cw / 5;

    // Bug body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(midX, midY), width: p * 2.8, height: p * 2.2),
      darkPaint,
    );
    // Bug head
    canvas.drawCircle(Offset(midX + (p * 1.4), midY), p * 0.8, darkPaint);
    // Bug legs (4 crawling spikes)
    canvas.drawLine(Offset(midX - p, midY - (p * 1.6)), Offset(midX - (p * 0.2), midY), darkPaint);
    canvas.drawLine(Offset(midX + p, midY - (p * 1.6)), Offset(midX + (p * 0.2), midY), darkPaint);
    canvas.drawLine(Offset(midX - p, midY + (p * 1.6)), Offset(midX - (p * 0.2), midY), darkPaint);
    canvas.drawLine(Offset(midX + p, midY + (p * 1.6)), Offset(midX + (p * 0.2), midY), darkPaint);
  }

  void _drawSnakeHead(
    Canvas canvas,
    Offset origin,
    double cw,
    double ch,
    Direction dir,
    Paint darkPaint,
    Paint eyePaint, {
    required bool isDead,
  }) {
    // Outer head
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + 0.5, origin.dy + 0.5, cw - 1, ch - 1),
      darkPaint,
    );

    // Eyes
    final double eyeSize = (cw / 3.5).clamp(1.5, 3.5);
    Offset eye1;
    Offset eye2;

    switch (dir) {
      case Direction.up:
        eye1 = Offset(origin.dx + 1.5, origin.dy + 1.5);
        eye2 = Offset(origin.dx + cw - eyeSize - 1.5, origin.dy + 1.5);
        break;
      case Direction.down:
        eye1 = Offset(origin.dx + 1.5, origin.dy + ch - eyeSize - 1.5);
        eye2 = Offset(origin.dx + cw - eyeSize - 1.5, origin.dy + ch - eyeSize - 1.5);
        break;
      case Direction.left:
        eye1 = Offset(origin.dx + 1.5, origin.dy + 1.5);
        eye2 = Offset(origin.dx + 1.5, origin.dy + ch - eyeSize - 1.5);
        break;
      case Direction.right:
        eye1 = Offset(origin.dx + cw - eyeSize - 1.5, origin.dy + 1.5);
        eye2 = Offset(origin.dx + cw - eyeSize - 1.5, origin.dy + ch - eyeSize - 1.5);
        break;
    }

    if (isDead) {
      // Draw dead eyes ('X')
      final xPaint = Paint()
        ..color = eyePaint.color
        ..strokeWidth = 1.0;
      canvas.drawLine(eye1, eye1 + Offset(eyeSize, eyeSize), xPaint);
      canvas.drawLine(eye1 + Offset(0, eyeSize), eye1 + Offset(eyeSize, 0), xPaint);
      canvas.drawLine(eye2, eye2 + Offset(eyeSize, eyeSize), xPaint);
      canvas.drawLine(eye2 + Offset(0, eyeSize), eye2 + Offset(eyeSize, 0), xPaint);
    } else {
      // Normal pixel pupils
      canvas.drawRect(
        Rect.fromLTWH(eye1.dx, eye1.dy, eyeSize, eyeSize),
        eyePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(eye2.dx, eye2.dy, eyeSize, eyeSize),
        eyePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) => true;
}
