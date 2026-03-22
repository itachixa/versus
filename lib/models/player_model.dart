class Player {
  String id;
  String name;
  String? photoPath;
  int totalPoints;
  int matchesPlayed;
  int wins;
  int losses;

  Player({
    required this.id,
    required this.name,
    this.photoPath,
    this.totalPoints = 0,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
  });

  double get averagePoints {
    if (matchesPlayed == 0) return 0;
    return totalPoints / matchesPlayed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
      'totalPoints': totalPoints,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'losses': losses,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      photoPath: json['photoPath'],
      totalPoints: json['totalPoints'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    String? photoPath,
    int? totalPoints,
    int? matchesPlayed,
    int? wins,
    int? losses,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      totalPoints: totalPoints ?? this.totalPoints,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  }
}
