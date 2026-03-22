import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_tournament.dart';
import '../models/local_match.dart';
import '../providers/local_tournament_provider.dart';
import '../widgets/local_team_card.dart';
import '../widgets/local_match_card.dart';
import 'referee_match_screen.dart';
import 'player_stats_page.dart';
import 'tournament_summary_page.dart';

class LocalTournamentDetailPage extends StatefulWidget {
  final LocalTournament tournament;

  const LocalTournamentDetailPage({required this.tournament});

  @override
  _LocalTournamentDetailPageState createState() => _LocalTournamentDetailPageState();
}

class _LocalTournamentDetailPageState extends State<LocalTournamentDetailPage>
    with SingleTickerProviderStateMixin {
  final _teamNameController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildTournamentTypeChip(),
            SizedBox(width: 8),
            Expanded(child: Text(widget.tournament.name)),
          ],
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teams'),
            Tab(text: 'Matches'),
            Tab(text: 'Schedule'),
            Tab(text: 'Stats'),
            Tab(text: 'Bracket'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTeamsTab(),
            _buildMatchesTab(),
            _buildScheduleTab(),
            _buildStatsTab(),
            _buildBracketTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTournamentTypeChip() {
    final isGroup = widget.tournament.tournamentType == TournamentType.groupStage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGroup ? Colors.blue.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isGroup ? Colors.blue : Colors.red),
      ),
      child: Text(
        isGroup ? 'GROUP' : 'KNOCKOUT',
        style: TextStyle(
          color: isGroup ? Colors.blue : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTeamsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _teamNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addTeam,
                child: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.tournament.teams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups, color: Colors.grey.shade600, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No teams yet',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add teams to start the tournament',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.tournament.teams.length,
                  itemBuilder: (context, index) {
                    final team = widget.tournament.teams[index];
                    final isLeading = _isLeadingTeam(team.id);
                    return LocalTeamCard(
                      team: team,
                      isLeading: isLeading,
                      onTap: () => _showTeamDetails(team),
                    );
                  },
                ),
        ),
        if (widget.tournament.teams.length >= 2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showGenerateMatchesDialog,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isLeadingTeam(String teamId) {
    if (widget.tournament.teams.isEmpty) return false;
    final leadingTeam = widget.tournament.teams.reduce((a, b) =>
        a.totalPoints > b.totalPoints ? a : b);
    return leadingTeam.id == teamId && leadingTeam.totalPoints > 0;
  }

  Widget _buildMatchesTab() {
    final pendingMatches = widget.tournament.matches
        .where((m) => !m.isCompleted)
        .toList();

    return Column(
      children: [
        if (pendingMatches.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.notification_important, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${pendingMatches.length} matches pending',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        Expanded(
          child: widget.tournament.matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_score, color: Colors.grey.shade600, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No matches yet',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.tournament.matches.length,
                  itemBuilder: (context, index) {
                    final match = widget.tournament.matches[index];
                    return LocalMatchCard(
                      match: match,
                      onScoreUpdate: _updateMatchScore,
                      tournament: widget.tournament,
                      onTap: () => _openRefereeMode(match),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    final rounds = <int>[];
    for (var match in widget.tournament.matches) {
      if (!rounds.contains(match.round)) {
        rounds.add(match.round);
      }
    }
    rounds.sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rounds.length,
      itemBuilder: (context, roundIndex) {
        final round = rounds[roundIndex];
        final roundMatches = widget.tournament.matches
            .where((m) => m.round == round)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round $round',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${roundMatches.where((m) => m.isCompleted).length}/${roundMatches.length}',
                    style: TextStyle(
                      color: roundMatches.every((m) => m.isCompleted)
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...roundMatches.map((match) => _buildScheduleMatchCard(match)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildScheduleMatchCard(LocalMatch match) {
    final team1 = widget.tournament.teams.firstWhere(
      (t) => t.id == match.team1Id,
      orElse: () => widget.tournament.teams.first,
    );
    final team2 = widget.tournament.teams.firstWhere(
      (t) => t.id == match.team2Id,
      orElse: () => widget.tournament.teams.first,
    );

    return GestureDetector(
      onTap: () => _openRefereeMode(match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: match.isCompleted
              ? Colors.green.withOpacity(0.1)
              : match.status == MatchStatus.inProgress
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: match.isCompleted
                ? Colors.green
                : match.status == MatchStatus.inProgress
                    ? Colors.orange
                    : Colors.grey.shade700,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                team1.name,
                style: TextStyle(
                  color: match.winnerId == team1.id && match.isCompleted
                      ? Colors.green
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${match.score1} - ${match.score2}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                team2.name,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: match.winnerId == team2.id && match.isCompleted
                      ? Colors.green
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return PlayerStatsPage(tournament: widget.tournament);
  }

  Widget _buildBracketTab() {
    if (widget.tournament.tournamentType == TournamentType.groupStage) {
      return _buildGroupStageBracket();
    }
    return _buildKnockoutBracket();
  }

  Widget _buildGroupStageBracket() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.tournament.groups.length,
      itemBuilder: (context, index) {
        final group = widget.tournament.groups[index];
        final groupTeams = widget.tournament.getGroupStandings(group.name);

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...groupTeams.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final team = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? Colors.amber
                              : rank == 2
                                  ? Colors.grey
                                  : rank == 3
                                      ? Colors.brown
                                      : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rank <= 3 ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          team.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        '${team.totalPoints} pts',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKnockoutBracket() {
    final rounds = <int>[];
    for (var match in widget.tournament.matches.where((m) => m.matchType == MatchType.knockout)) {
      if (!rounds.contains(match.round)) {
        rounds.add(match.round);
      }
    }
    rounds.sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rounds.length,
      itemBuilder: (context, index) {
        final round = rounds[index];
        final roundMatches = widget.tournament.matches
            .where((m) => m.round == round && m.matchType == MatchType.knockout)
            .toList();

        String roundName;
        if (round == rounds.length) {
          roundName = 'Final';
        } else if (round == rounds.length - 1) {
          roundName = 'Semi-Finals';
        } else {
          roundName = 'Round $round';
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roundName,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...roundMatches.map((match) => _buildKnockoutMatchCard(match)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildKnockoutMatchCard(LocalMatch match) {
    final team1 = widget.tournament.teams.firstWhere(
      (t) => t.id == match.team1Id,
      orElse: () => widget.tournament.teams.first,
    );
    final team2 = widget.tournament.teams.firstWhere(
      (t) => t.id == match.team2Id,
      orElse: () => widget.tournament.teams.first,
    );

    return GestureDetector(
      onTap: () => _openRefereeMode(match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: match.isCompleted ? Colors.green.withOpacity(0.2) : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: match.isCompleted ? Colors.green : Colors.grey.shade700,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team1.name,
                    style: TextStyle(
                      color: match.winnerId == team1.id ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (match.isCompleted)
                    Text(
                      '${match.score1} pts',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                match.isCompleted ? 'VS' : 'TAP',
                style: TextStyle(
                  color: match.isCompleted ? Colors.white : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    team2.name,
                    style: TextStyle(
                      color: match.winnerId == team2.id ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (match.isCompleted)
                    Text(
                      '${match.score2} pts',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    final completedMatches = widget.tournament.matches.where((m) => m.isCompleted).length;
    final totalMatches = widget.tournament.matches.length;
    final isComplete = totalMatches > 0 && completedMatches == totalMatches;

    if (isComplete) {
      return FloatingActionButton.extended(
        onPressed: _showTournamentSummary,
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.emoji_events, color: Colors.black),
        label: const Text('Tournament Summary', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      );
    }

    if (widget.tournament.matches.isEmpty) {
      return null;
    }

    final nextMatch = widget.tournament.currentRoundMatches.isNotEmpty
        ? widget.tournament.currentRoundMatches.first
        : null;

    if (nextMatch == null && widget.tournament.tournamentType == TournamentType.knockout) {
      final pendingMatch = widget.tournament.matches.where((m) => !m.isCompleted).firstOrNull;
      if (pendingMatch != null) {
        return FloatingActionButton.extended(
          onPressed: () => _openRefereeMode(pendingMatch),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Next Match'),
        );
      }
      return null;
    }

    if (nextMatch == null) return null;

    return FloatingActionButton.extended(
      onPressed: () => _openRefereeMode(nextMatch),
      backgroundColor: Colors.green,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Next Match'),
    );
  }

  void _showTournamentSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentSummaryPage(
          tournament: widget.tournament,
          onClose: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _addTeam() {
    if (_teamNameController.text.isEmpty || widget.tournament.teams.length >= 16) return;

    setState(() {
      widget.tournament.addTeam(_teamNameController.text);
    });
    _teamNameController.clear();
    _saveTournament();
  }

  void _showGenerateMatchesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Generate Matches', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Group Stage', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Pools with round-robin', style: TextStyle(color: Colors.grey)),
              leading: Radio<TournamentType>(
                value: TournamentType.groupStage,
                groupValue: widget.tournament.tournamentType,
                onChanged: (value) {
                  setState(() {
                    widget.tournament.tournamentType = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  widget.tournament.tournamentType = TournamentType.groupStage;
                });
              },
            ),
            ListTile(
              title: const Text('Knockout', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Direct elimination', style: TextStyle(color: Colors.grey)),
              leading: Radio<TournamentType>(
                value: TournamentType.knockout,
                groupValue: widget.tournament.tournamentType,
                onChanged: (value) {
                  setState(() {
                    widget.tournament.tournamentType = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  widget.tournament.tournamentType = TournamentType.knockout;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateMatches();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _generateMatches() {
    setState(() {
      if (widget.tournament.tournamentType == TournamentType.groupStage) {
        widget.tournament.generateGroupStageMatches();
      } else {
        widget.tournament.generateKnockoutMatches();
      }
    });
    _saveTournament();
  }

  void _updateMatchScore(LocalMatch match, int score1, int score2) {
    setState(() {
      match.score1 = score1;
      match.score2 = score2;
      match.isCompleted = true;
      match.winnerId = score1 > score2
          ? match.team1Id
          : score2 > score1
              ? match.team2Id
              : null;
      widget.tournament.updateStandings();
      widget.tournament.advanceWinners();
    });
    _saveTournament();
  }

  void _openRefereeMode(LocalMatch match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RefereeMatchScreen(
          match: match,
          tournament: widget.tournament,
          onMatchUpdate: (updatedMatch) {
            setState(() {
              final index = widget.tournament.matches.indexWhere((m) => m.id == updatedMatch.id);
              if (index != -1) {
                widget.tournament.matches[index] = updatedMatch;
              }
              widget.tournament.updateStandings();
            });
            _saveTournament();
          },
        ),
      ),
    );
  }

  void _showTeamDetails(team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTeamStatChip('W', team.wins.toString(), Colors.green),
                const SizedBox(width: 8),
                _buildTeamStatChip('L', team.losses.toString(), Colors.red),
                const SizedBox(width: 8),
                _buildTeamStatChip('D', team.draws.toString(), Colors.grey),
                const SizedBox(width: 8),
                _buildTeamStatChip('PTS', team.totalPoints.toString(), Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Players:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            if (team.players.isEmpty)
              const Text('No players added', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: team.players.map<Widget>((player) => Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(player.name[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  label: Text(player.name),
                  backgroundColor: Colors.grey.shade800,
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _saveTournament() {
    context.read<LocalTournamentProvider>().updateTournament(widget.tournament);
  }
}
