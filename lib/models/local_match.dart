import 'player_model.dart';

enum MatchStatus { pending, inProgress, completed }

enum MatchType { groupStage, knockout, final_ }

class LocalMatch {
  String id;
  String team1Id;
  String team2Id;
  int score1;
  int score2;
  bool isCompleted;
  int timerMinutes;
  MatchStatus status;
  MatchType matchType;
  int round;
  int matchNumber;
  String? winnerId;
  String? nextMatchId;
  Map<String, int> player1Points;
  Map<String, int> player2Points;

  LocalMatch({
    required this.id,
    required this.team1Id,
    required this.team2Id,
    this.score1 = 0,
    this.score2 = 0,
    this.isCompleted = false,
    this.timerMinutes = 5,
    this.status = MatchStatus.pending,
    this.matchType = MatchType.groupStage,
    this.round = 1,
    this.matchNumber = 1,
    this.winnerId,
    this.nextMatchId,
    Map<String, int>? player1Points,
    Map<String, int>? player2Points,
  })  : player1Points = player1Points ?? {},
        player2Points = player2Points ?? {};

  int get team1TotalPoints {
    return player1Points.values.fold(0, (sum, pts) => sum + pts);
  }

  int get team2TotalPoints {
    return player2Points.values.fold(0, (sum, pts) => sum + pts);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'score1': score1,
      'score2': score2,
      'isCompleted': isCompleted,
      'timerMinutes': timerMinutes,
      'status': status.index,
      'matchType': matchType.index,
      'round': round,
      'matchNumber': matchNumber,
      'winnerId': winnerId,
      'nextMatchId': nextMatchId,
      'player1Points': player1Points,
      'player2Points': player2Points,
    };
  }

  factory LocalMatch.fromJson(Map<String, dynamic> json) {
    return LocalMatch(
      id: json['id'],
      team1Id: json['team1Id'],
      team2Id: json['team2Id'],
      score1: json['score1'] ?? 0,
      score2: json['score2'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      timerMinutes: json['timerMinutes'] ?? 5,
      status: MatchStatus.values[json['status'] ?? 0],
      matchType: MatchType.values[json['matchType'] ?? 0],
      round: json['round'] ?? 1,
      matchNumber: json['matchNumber'] ?? 1,
      winnerId: json['winnerId'],
      nextMatchId: json['nextMatchId'],
      player1Points: Map<String, int>.from(json['player1Points'] ?? {}),
      player2Points: Map<String, int>.from(json['player2Points'] ?? {}),
    );
  }

  LocalMatch copyWith({
    String? id,
    String? team1Id,
    String? team2Id,
    int? score1,
    int? score2,
    bool? isCompleted,
    int? timerMinutes,
    MatchStatus? status,
    MatchType? matchType,
    int? round,
    int? matchNumber,
    String? winnerId,
    String? nextMatchId,
    Map<String, int>? player1Points,
    Map<String, int>? player2Points,
  }) {
    return LocalMatch(
      id: id ?? this.id,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      isCompleted: isCompleted ?? this.isCompleted,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      status: status ?? this.status,
      matchType: matchType ?? this.matchType,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      winnerId: winnerId ?? this.winnerId,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      player1Points: player1Points ?? this.player1Points,
      player2Points: player2Points ?? this.player2Points,
    );
  }
}
