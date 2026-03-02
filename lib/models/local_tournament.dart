import 'local_match.dart';
import 'local_team.dart';

class LocalTournament {
  String id;
  String name;
  DateTime createdAt;
  int matchType; // 1 for 1v1, 2 for 2v2, etc.
  int timerMinutes; // 5,10,15
  List<LocalTeam> teams;
  List<LocalMatch> matches;
  Map<String, int> standings; // teamId -> points

  LocalTournament({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.matchType,
    required this.timerMinutes,
    required this.teams,
    required this.matches,
    required this.standings,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'matchType': matchType,
      'timerMinutes': timerMinutes,
      'teams': teams.map((t) => t.toJson()).toList(),
      'matches': matches.map((m) => m.toJson()).toList(),
      'standings': standings,
    };
  }

  factory LocalTournament.fromJson(Map<String, dynamic> json) {
    return LocalTournament(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      matchType: json['matchType'],
      timerMinutes: json['timerMinutes'],
      teams: (json['teams'] as List).map((t) => LocalTeam.fromJson(t)).toList(),
      matches: (json['matches'] as List).map((m) => LocalMatch.fromJson(m)).toList(),
      standings: Map<String, int>.from(json['standings']),
    );
  }

  // Helper methods
  void addTeam(String teamName) {
    if (teams.length < 8) {
      String teamId = 'team_${teams.length + 1}';
      teams.add(LocalTeam(id: teamId, name: teamName, players: []));
    }
  }

  void generateMatches() {
    // Simple round-robin for now, but for elimination, need bracket
    // For simplicity, assume round-robin
    matches.clear();
    for (int i = 0; i < teams.length; i++) {
      for (int j = i + 1; j < teams.length; j++) {
        matches.add(LocalMatch(
          id: 'match_${matches.length + 1}',
          team1Id: teams[i].id,
          team2Id: teams[j].id,
          score1: 0,
          score2: 0,
          isCompleted: false,
          timerMinutes: timerMinutes,
        ));
      }
    }
  }

  void updateStandings() {
    standings.clear();
    for (var team in teams) {
      standings[team.id] = 0;
    }
    for (var match in matches) {
      if (match.isCompleted) {
        if (match.score1 > match.score2) {
          standings[match.team1Id] = (standings[match.team1Id] ?? 0) + 3;
        } else if (match.score2 > match.score1) {
          standings[match.team2Id] = (standings[match.team2Id] ?? 0) + 3;
        } else {
          standings[match.team1Id] = (standings[match.team1Id] ?? 0) + 1;
          standings[match.team2Id] = (standings[match.team2Id] ?? 0) + 1;
        }
      }
    }
  }
}