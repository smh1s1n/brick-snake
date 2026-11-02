import 'package:flutter/foundation.dart';
import 'direction.dart';
import 'position.dart';

class Snake {
  final List<Position> body;
  final Direction direction;
  final bool isAlive;

  const Snake({
    required this.body,
    required this.direction,
    this.isAlive = true,
  });

  Position get head => body.first;
  List<Position> get tail => body.sublist(1);
  int get length => body.length;

  /// Creates an initial snake of [length] moving in [direction].
  factory Snake.initial({
    required Position startHead,
    required Direction direction,
    int length = 4,
  }) {
    final List<Position> segments = [];
    final Position stepBack = direction.isOpposite(Direction.right)
        ? const Position(1, 0)
        : direction == Direction.right
            ? const Position(-1, 0)
            : direction == Direction.down
                ? const Position(0, -1)
                : const Position(0, 1);

    for (int i = 0; i < length; i++) {
      segments.add(startHead.translate(stepBack.x * i, stepBack.y * i));
    }
    return Snake(
      body: List.unmodifiable(segments),
      direction: direction,
      isAlive: true,
    );
  }

  /// Advance the snake by placing newHead. If grow is false, the last tail segment is removed.
  Snake move({
    required Position newHead,
    required Direction newDirection,
    required bool grow,
    bool alive = true,
  }) {
    final List<Position> newBody = [newHead, ...body];
    if (!grow) {
      newBody.removeLast();
    }
    return Snake(
      body: List.unmodifiable(newBody),
      direction: newDirection,
      isAlive: alive,
    );
  }

  /// Check if the snake's head hits any segment in its body (excluding the head itself).
  bool collidesWithSelf() {
    for (int i = 1; i < body.length; i++) {
      if (body[i] == head) {
        return true;
      }
    }
    return false;
  }

  bool occupies(Position pos) {
    return body.contains(pos);
  }

  Snake die() {
    return Snake(
      body: body,
      direction: direction,
      isAlive: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Snake &&
          runtimeType == other.runtimeType &&
          isAlive == other.isAlive &&
          direction == other.direction &&
          listEquals(body, other.body);

  @override
  int get hashCode => Object.hash(
        direction,
        isAlive,
        Object.hashAll(body),
      );
}
