import 'local_match.dart';
import 'local_team.dart';
import 'player_model.dart';

enum TournamentType { groupStage, knockout }

class Group {
  String name;
  List<String> teamIds;

  Group({required this.name, required this.teamIds});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teamIds': teamIds,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
      teamIds: List<String>.from(json['teamIds']),
    );
  }
}

class LocalTournament {
  String id;
  String name;
  DateTime createdAt;
  int matchType;
  int timerMinutes;
  List<LocalTeam> teams;
  List<LocalMatch> matches;
  Map<String, int> standings;
  TournamentType tournamentType;
  List<Group> groups;
  int currentRound;
  int maxTeamsPerGroup;
  String? winnerId;
  bool isCompleted;

  LocalTournament({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.matchType,
    required this.timerMinutes,
    required this.teams,
    required this.matches,
    required this.standings,
    this.tournamentType = TournamentType.knockout,
    this.groups = const [],
    this.currentRound = 1,
    this.maxTeamsPerGroup = 4,
    this.winnerId,
    this.isCompleted = false,
  });

  List<LocalMatch> get currentRoundMatches {
    return matches.where((m) => m.round == currentRound && !m.isCompleted).toList();
  }

  List<LocalMatch> get completedMatches {
    return matches.where((m) => m.isCompleted).toList();
  }

  List<LocalMatch> get knockoutMatches {
    return matches.where((m) => m.matchType == MatchType.knockout).toList();
  }

  List<LocalMatch> get groupMatches {
    return matches.where((m) => m.matchType == MatchType.groupStage).toList();
  }

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
      'tournamentType': tournamentType.index,
      'groups': groups.map((g) => g.toJson()).toList(),
      'currentRound': currentRound,
      'maxTeamsPerGroup': maxTeamsPerGroup,
      'winnerId': winnerId,
      'isCompleted': isCompleted,
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
      tournamentType: TournamentType.values[json['tournamentType'] ?? 1],
      groups: (json['groups'] as List?)?.map((g) => Group.fromJson(g)).toList() ?? [],
      currentRound: json['currentRound'] ?? 1,
      maxTeamsPerGroup: json['maxTeamsPerGroup'] ?? 4,
      winnerId: json['winnerId'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  void addTeam(String teamName) {
    if (teams.length < 16) {
      String teamId = 'team_${teams.length + 1}';
      teams.add(LocalTeam(id: teamId, name: teamName, players: []));
    }
  }

  void addPlayerToTeam(String teamId, String playerName) {
    final teamIndex = teams.indexWhere((t) => t.id == teamId);
    if (teamIndex != -1) {
      final playerId = '${teamId}_player_${teams[teamIndex].players.length + 1}';
      teams[teamIndex].players.add(
        Player(id: playerId, name: playerName),
      );
    }
  }

  void generateGroupStageMatches() {
    matches.clear();
    if (groups.isEmpty) {
      _createGroups();
    }

    int matchNum = 1;
    for (var group in groups) {
      final groupTeams = teams.where((t) => group.teamIds.contains(t.id)).toList();
      for (int i = 0; i < groupTeams.length; i++) {
        for (int j = i + 1; j < groupTeams.length; j++) {
          matches.add(LocalMatch(
            id: 'match_$matchNum',
            team1Id: groupTeams[i].id,
            team2Id: groupTeams[j].id,
            matchType: MatchType.groupStage,
            round: groups.indexOf(group) + 1,
            matchNumber: matchNum,
            timerMinutes: timerMinutes,
          ));
          matchNum++;
        }
      }
    }
  }

  void _createGroups() {
    groups.clear();
    final numGroups = (teams.length / maxTeamsPerGroup).ceil();
    for (int i = 0; i < numGroups; i++) {
      final groupTeams = teams
          .skip(i * maxTeamsPerGroup)
          .take(maxTeamsPerGroup)
          .map((t) => t.id)
          .toList();
      if (groupTeams.length >= 2) {
        groups.add(Group(name: 'Group ${String.fromCharCode(65 + i)}', teamIds: groupTeams));
      }
    }
  }

  void generateKnockoutMatches() {
    matches.clear();
    final sortedTeams = List<LocalTeam>.from(teams);
    sortedTeams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    int round = 1;
    int numTeams = sortedTeams.length;
    int matchNum = 1;

    while (numTeams > 1) {
      int matchesThisRound = numTeams ~/ 2;
      for (int i = 0; i < matchesThisRound; i++) {
        matches.add(LocalMatch(
          id: 'match_$matchNum',
          team1Id: sortedTeams[i].id,
          team2Id: sortedTeams[numTeams - 1 - i].id,
          matchType: MatchType.knockout,
          round: round,
          matchNumber: matchNum,
          timerMinutes: timerMinutes,
        ));
        matchNum++;
      }
      round++;
      numTeams = matchesThisRound;
    }
  }

  void updateStandings() {
    standings.clear();
    for (var team in teams) {
      standings[team.id] = team.totalPoints;
    }

    for (var match in matches) {
      if (match.isCompleted) {
        final team1 = teams.firstWhere((t) => t.id == match.team1Id);
        final team2 = teams.firstWhere((t) => t.id == match.team2Id);

        if (match.score1 > match.score2) {
          team1.wins++;
          team2.losses++;
          team1.totalPoints += 3;
        } else if (match.score2 > match.score1) {
          team2.wins++;
          team1.losses++;
          team2.totalPoints += 3;
        } else {
          team1.draws++;
          team2.draws++;
          team1.totalPoints += 1;
          team2.totalPoints += 1;
        }
      }
    }
  }

  void advanceWinners() {
    if (tournamentType != TournamentType.knockout) return;

    final completedThisRound = matches.where((m) => m.round == currentRound && m.isCompleted).toList();
    final totalThisRound = matches.where((m) => m.round == currentRound).length;

    if (completedThisRound.length == totalThisRound && totalThisRound > 0) {
      currentRound++;
      
      final nextRoundMatches = matches.where((m) => m.round == currentRound).toList();
      final winners = completedThisRound
          .where((m) => m.winnerId != null)
          .map((m) => m.winnerId!)
          .toList();

      for (int i = 0; i < nextRoundMatches.length && i * 2 + 1 < winners.length; i++) {
        nextRoundMatches[i].team1Id = winners[i * 2];
        nextRoundMatches[i].team2Id = winners[i * 2 + 1];
      }

      if (nextRoundMatches.length == 1 && winners.length == 2) {
        winnerId = null;
        isCompleted = false;
      }
    }
  }

  LocalTeam? getWinner() {
    if (winnerId != null) {
      return teams.firstWhere((t) => t.id == winnerId, orElse: () => teams.first);
    }
    
    if (tournamentType == TournamentType.knockout) {
      final finalMatch = matches.where((m) => m.matchType == MatchType.final_ && m.isCompleted).firstOrNull;
      if (finalMatch != null) {
        return teams.firstWhere((t) => t.id == finalMatch.winnerId, orElse: () => teams.first);
      }
    }
    return null;
  }

  List<LocalTeam> getGroupStandings(String groupName) {
    final group = groups.firstWhere((g) => g.name == groupName);
    final groupTeams = teams.where((t) => group.teamIds.contains(t.id)).toList();
    groupTeams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return groupTeams;
  }
}
