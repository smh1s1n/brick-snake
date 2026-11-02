class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position operator +(Position other) => Position(x + other.x, y + other.y);

  Position translate(int dx, int dy) => Position(x + dx, y + dy);

  Position wrap(int width, int height) {
    int nx = x % width;
    if (nx < 0) nx += width;
    int ny = y % height;
    if (ny < 0) ny += height;
    return Position(nx, ny);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Position($x, $y)';
}
