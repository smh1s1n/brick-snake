import 'package:flutter_test/flutter_test.dart';
import 'package:nokia_snake/core/audio/sound_generator.dart';
import 'package:nokia_snake/core/constants/game_constants.dart';
import 'package:nokia_snake/domain/models/bonus_food.dart';
import 'package:nokia_snake/domain/models/direction.dart';
import 'package:nokia_snake/domain/models/maze.dart';
import 'package:nokia_snake/domain/models/position.dart';
import 'package:nokia_snake/domain/models/snake.dart';

void main() {
  group('Position Tests', () {
    test('Position addition and translation', () {
      const p1 = Position(5, 5);
      const p2 = Position(2, -3);
      expect(p1 + p2, equals(const Position(7, 2)));
      expect(p1.translate(1, 1), equals(const Position(6, 6)));
    });

    test('Position wrapping around boundaries', () {
      const p = Position(24, 16);
      expect(p.wrap(24, 16), equals(const Position(0, 0)));

      const pNeg = Position(-1, -1);
      expect(pNeg.wrap(24, 16), equals(const Position(23, 15)));
    });
  });

  group('Direction Tests', () {
    test('Opposite directions prevention', () {
      expect(Direction.up.isOpposite(Direction.down), isTrue);
      expect(Direction.down.isOpposite(Direction.up), isTrue);
      expect(Direction.left.isOpposite(Direction.right), isTrue);
      expect(Direction.right.isOpposite(Direction.left), isTrue);
      expect(Direction.up.isOpposite(Direction.left), isFalse);
    });

    test('Direction deltas', () {
      expect(Direction.up.delta, equals(const Position(0, -1)));
      expect(Direction.down.delta, equals(const Position(0, 1)));
      expect(Direction.left.delta, equals(const Position(-1, 0)));
      expect(Direction.right.delta, equals(const Position(1, 0)));
    });
  });

  group('Snake Entity Tests', () {
    test('Initial snake segments', () {
      final snake = Snake.initial(
        startHead: const Position(6, 6),
        direction: Direction.right,
        length: 4,
      );

      expect(snake.length, equals(4));
      expect(snake.head, equals(const Position(6, 6)));
      expect(snake.direction, equals(Direction.right));
      expect(snake.isAlive, isTrue);
      expect(snake.body, equals([
        const Position(6, 6),
        const Position(5, 6),
        const Position(4, 6),
        const Position(3, 6),
      ]));
    });

    test('Snake movement without growth', () {
      final snake = Snake.initial(
        startHead: const Position(6, 6),
        direction: Direction.right,
        length: 4,
      );

      final moved = snake.move(
        newHead: const Position(7, 6),
        newDirection: Direction.right,
        grow: false,
      );

      expect(moved.length, equals(4));
      expect(moved.head, equals(const Position(7, 6)));
      expect(moved.body.last, equals(const Position(4, 6)));
      // Crucial: moved snake must NOT equal previous snake so Riverpod state change fires
      expect(moved, isNot(equals(snake)));
    });

    test('Snake movement with growth', () {
      final snake = Snake.initial(
        startHead: const Position(6, 6),
        direction: Direction.right,
        length: 4,
      );

      final grown = snake.move(
        newHead: const Position(7, 6),
        newDirection: Direction.right,
        grow: true,
      );

      expect(grown.length, equals(5));
      expect(grown.head, equals(const Position(7, 6)));
      expect(grown.body.last, equals(const Position(3, 6)));
    });

    test('Snake self-collision detection', () {
      // Create snake looping into itself
      final snake = Snake(
        body: const [
          Position(5, 5),
          Position(5, 6),
          Position(6, 6),
          Position(6, 5),
          Position(5, 5), // collision at head
        ],
        direction: Direction.left,
        isAlive: true,
      );

      expect(snake.collidesWithSelf(), isTrue);
    });
  });

  group('Maze Tests', () {
    test('Maze generation creates all 5 types', () {
      for (final type in MazeType.values) {
        final maze = Maze.create(type, GameConstants.boardWidth, GameConstants.boardHeight);
        expect(maze.type, equals(type));
        if (type == MazeType.openBorder) {
          expect(maze.walls, isEmpty);
          expect(maze.isWrapped, isTrue);
        } else if (type == MazeType.boxBorder) {
          expect(maze.walls, isNotEmpty);
          expect(maze.isWrapped, isFalse);
          expect(maze.hasWall(const Position(0, 0)), isTrue);
        }
      }
    });
  });

  group('BonusFood Tests', () {
    test('Bonus food ticks and expires', () {
      final bonus = BonusFood(
        position: const Position(10, 10),
        remainingTicks: 2,
        maxTicks: 2,
      );

      expect(bonus.isExpired, isFalse);
      expect(bonus.progress, equals(1.0));

      final ticked1 = bonus.tick();
      expect(ticked1.remainingTicks, equals(1));
      expect(ticked1.isExpired, isFalse);

      final ticked2 = ticked1.tick();
      expect(ticked2.remainingTicks, equals(0));
      expect(ticked2.isExpired, isTrue);
    });
  });

  group('Sound Generator Tests', () {
    test('SoundGenerator creates valid RIFF/WAVE header', () {
      final wav = SoundGenerator.eatFood();
      expect(wav.length, greaterThan(44));
      // "RIFF"
      expect(wav[0], equals(0x52));
      expect(wav[1], equals(0x49));
      expect(wav[2], equals(0x46));
      expect(wav[3], equals(0x46));
      // "WAVE"
      expect(wav[8], equals(0x57));
      expect(wav[9], equals(0x41));
      expect(wav[10], equals(0x56));
      expect(wav[11], equals(0x45));
    });
  });
}
