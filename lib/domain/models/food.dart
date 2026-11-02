import 'position.dart';

class Food {
  final Position position;

  const Food(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          runtimeType == other.runtimeType &&
          position == other.position;

  @override
  int get hashCode => position.hashCode;
}
