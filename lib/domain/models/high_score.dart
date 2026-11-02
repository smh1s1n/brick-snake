import 'maze.dart';

class HighScore {
  final int score;
  final int level;
  final MazeType mazeType;
  final DateTime date;

  const HighScore({
    required this.score,
    required this.level,
    required this.mazeType,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'level': level,
        'mazeType': mazeType.name,
        'date': date.toIso8601String(),
      };

  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      score: json['score'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      mazeType: MazeType.values.firstWhere(
        (m) => m.name == json['mazeType'],
        orElse: () => MazeType.openBorder,
      ),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'HighScore(score: $score, level: $level, maze: ${mazeType.title})';
}
