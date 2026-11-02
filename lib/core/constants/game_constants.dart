class GameConstants {
  // Grid Dimensions
  static const int boardWidth = 24;
  static const int boardHeight = 16;

  // Starting Snake
  static const int initialSnakeLength = 4;
  static const int initialSnakeX = 6;
  static const int initialSnakeY = 8;

  // Speed timings in milliseconds for levels 1 to 9 (fast, snappy, responsive)
  static const List<int> speedMilliseconds = [
    160, // Level 1
    135, // Level 2
    115, // Level 3
    95,  // Level 4
    80,  // Level 5
    65,  // Level 6
    50,  // Level 7
    40,  // Level 8
    30,  // Level 9
  ];

  // Scoring
  static int baseFoodScore(int level) => level * 10;
  static int bonusFoodScore(int level, int ticksRemaining) =>
      (level * 15) + (ticksRemaining * 5);

  // Bonus food interval & lifetime
  static const int foodsPerBonus = 5;
  static const int bonusLifetimeTicks = 35; // moves before disappearing
}
