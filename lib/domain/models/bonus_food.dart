import 'position.dart';

enum BonusType {
  insect,
  spider,
  fly,
}

class BonusFood {
  final Position position;
  final int remainingTicks;
  final int maxTicks;
  final BonusType type;

  const BonusFood({
    required this.position,
    required this.remainingTicks,
    required this.maxTicks,
    this.type = BonusType.insect,
  });

  bool get isExpired => remainingTicks <= 0;

  double get progress => remainingTicks / maxTicks;

  BonusFood tick() {
    return BonusFood(
      position: position,
      remainingTicks: remainingTicks - 1,
      maxTicks: maxTicks,
      type: type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusFood &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          remainingTicks == other.remainingTicks &&
          maxTicks == other.maxTicks &&
          type == other.type;

  @override
  int get hashCode =>
      position.hashCode ^
      remainingTicks.hashCode ^
      maxTicks.hashCode ^
      type.hashCode;
}
