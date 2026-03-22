import 'player_model.dart';

class LocalTeam {
  String id;
  String name;
  List<Player> players;
  int wins;
  int losses;
  int draws;
  int totalPoints;

  LocalTeam({
    required this.id,
    required this.name,
    required this.players,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.totalPoints = 0,
  });

  int get totalTeamPoints {
    return players.fold(0, (sum, player) => sum + player.totalPoints);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players.map((p) => p.toJson()).toList(),
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'totalPoints': totalPoints,
    };
  }

  factory LocalTeam.fromJson(Map<String, dynamic> json) {
    return LocalTeam(
      id: json['id'],
      name: json['name'],
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p))
          .toList(),
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  LocalTeam copyWith({
    String? id,
    String? name,
    List<Player>? players,
    int? wins,
    int? losses,
    int? draws,
    int? totalPoints,
  }) {
    return LocalTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
