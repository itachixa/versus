class Match {
  final String id;
  final String tournamentId;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final bool isCompleted;

  Match({
    required this.id,
    required this.tournamentId,
    required this.teamA,
    required this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.isCompleted = false,
  });

  factory Match.fromMap(String id, Map<String, dynamic> data) {
    return Match(
      id: id,
      tournamentId: data['tournamentId'],
      teamA: data['teamA'],
      teamB: data['teamB'],
      scoreA: data['scoreA'] ?? 0,
      scoreB: data['scoreB'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'teamA': teamA,
      'teamB': teamB,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'isCompleted': isCompleted,
    };
  }
}