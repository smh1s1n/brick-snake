import 'position.dart';

enum MazeType {
  openBorder(1, 'Open (Wrap)'),
  boxBorder(2, 'Solid Box'),
  tunnel(3, 'Tunnel'),
  mill(4, 'Mill'),
  rails(5, 'Rails');

  final int id;
  final String title;
  const MazeType(this.id, this.title);
}

class Maze {
  final MazeType type;
  final Set<Position> walls;
  final bool isWrapped; // Whether snake wraps across board edges

  const Maze({
    required this.type,
    required this.walls,
    required this.isWrapped,
  });

  bool hasWall(Position pos) => walls.contains(pos);

  /// Factory generator for classic Nokia mazes based on board dimensions
  factory Maze.create(MazeType type, int width, int height) {
    final Set<Position> walls = {};
    bool isWrapped = false;

    switch (type) {
      case MazeType.openBorder:
        // No walls at all, wraps continuously around all 4 screen edges
        isWrapped = true;
        break;

      case MazeType.boxBorder:
        // Solid outer wall perimeter
        isWrapped = false;
        for (int x = 0; x < width; x++) {
          walls.add(Position(x, 0));
          walls.add(Position(x, height - 1));
        }
        for (int y = 0; y < height; y++) {
          walls.add(Position(0, y));
          walls.add(Position(width - 1, y));
        }
        break;

      case MazeType.tunnel:
        // Two long horizontal barrier lines inside with gaps at ends, open borders
        isWrapped = true;
        final int topY = (height / 3).round();
        final int bottomY = ((height * 2) / 3).round();
        for (int x = 4; x < width - 4; x++) {
          walls.add(Position(x, topY));
          walls.add(Position(x, bottomY));
        }
        break;

      case MazeType.mill:
        // Central obstacle cross / 4 corner L-shapes, open borders
        isWrapped = true;
        final int midX = width ~/ 2;
        final int midY = height ~/ 2;
        // Central block
        for (int dx = -2; dx <= 2; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if (dx == 0 || dy == 0) {
              walls.add(Position(midX + dx, midY + dy));
            }
          }
        }
        // Corner pillars
        walls.add(const Position(4, 3));
        walls.add(const Position(4, 4));
        walls.add(Position(width - 5, 3));
        walls.add(Position(width - 5, 4));
        walls.add(Position(4, height - 4));
        walls.add(Position(4, height - 5));
        walls.add(Position(width - 5, height - 4));
        walls.add(Position(width - 5, height - 5));
        break;

      case MazeType.rails:
        // Parallel maze barriers alternating
        isWrapped = false;
        // Outer border
        for (int x = 0; x < width; x++) {
          walls.add(Position(x, 0));
          walls.add(Position(x, height - 1));
        }
        for (int y = 0; y < height; y++) {
          walls.add(Position(0, y));
          walls.add(Position(width - 1, y));
        }
        // Rail 1
        for (int y = 3; y < height - 3; y++) {
          walls.add(Position(width ~/ 3, y));
        }
        // Rail 2
        for (int y = 3; y < height - 3; y++) {
          walls.add(Position((width * 2) ~/ 3, y));
        }
        break;
    }

    return Maze(
      type: type,
      walls: walls,
      isWrapped: isWrapped,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Maze &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          isWrapped == other.isWrapped &&
          walls.length == other.walls.length;

  @override
  int get hashCode => type.hashCode ^ isWrapped.hashCode ^ walls.length.hashCode;
}
