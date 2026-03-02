class LocalMatch {
  String id;
  String team1Id;
  String team2Id;
  int score1;
  int score2;
  bool isCompleted;
  int timerMinutes;

  LocalMatch({
    required this.id,
    required this.team1Id,
    required this.team2Id,
    required this.score1,
    required this.score2,
    required this.isCompleted,
    required this.timerMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'score1': score1,
      'score2': score2,
      'isCompleted': isCompleted,
      'timerMinutes': timerMinutes,
    };
  }

  factory LocalMatch.fromJson(Map<String, dynamic> json) {
    return LocalMatch(
      id: json['id'],
      team1Id: json['team1Id'],
      team2Id: json['team2Id'],
      score1: json['score1'],
      score2: json['score2'],
      isCompleted: json['isCompleted'],
      timerMinutes: json['timerMinutes'],
    );
  }
}