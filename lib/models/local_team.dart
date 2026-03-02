class LocalTeam {
  String id;
  String name;
  List<String> players; // For team modes, list of player names

  LocalTeam({
    required this.id,
    required this.name,
    required this.players,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players,
    };
  }

  factory LocalTeam.fromJson(Map<String, dynamic> json) {
    return LocalTeam(
      id: json['id'],
      name: json['name'],
      players: List<String>.from(json['players']),
    );
  }
}