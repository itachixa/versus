import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_tournament.dart';
import '../models/local_team.dart';
import '../models/local_match.dart';
import '../providers/local_tournament_provider.dart';
import '../widgets/local_team_card.dart';
import '../widgets/local_match_card.dart';

class LocalTournamentDetailPage extends StatefulWidget {
  final LocalTournament tournament;

  LocalTournamentDetailPage({required this.tournament});

  @override
  _LocalTournamentDetailPageState createState() => _LocalTournamentDetailPageState();
}

class _LocalTournamentDetailPageState extends State<LocalTournamentDetailPage> {
  final _teamNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Équipes'),
                  Tab(text: 'Matchs'),
                  Tab(text: 'Classement'),
                  Tab(text: 'Bracket'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTeamsTab(),
                    _buildMatchesTab(),
                    _buildStandingsTab(),
                    _buildBracketTab(),
                  ],
                ),
              ),
            ],
          ),
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'équipe',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addTeam,
                child: Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.tournament.teams.length,
            itemBuilder: (context, index) {
              return LocalTeamCard(team: widget.tournament.teams[index]);
            },
          ),
        ),
        if (widget.tournament.teams.length >= 2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _generateMatches,
              child: Text('Générer les matchs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchesTab() {
    return ListView.builder(
      itemCount: widget.tournament.matches.length,
      itemBuilder: (context, index) {
        return LocalMatchCard(
          match: widget.tournament.matches[index],
          onScoreUpdate: _updateMatchScore,
          tournament: widget.tournament,
        );
      },
    );
  }

  Widget _buildStandingsTab() {
    final sortedStandings = widget.tournament.standings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      itemCount: sortedStandings.length,
      itemBuilder: (context, index) {
        final entry = sortedStandings[index];
        final team = widget.tournament.teams.firstWhere((t) => t.id == entry.key);
        return ListTile(
          title: Text(team.name, style: TextStyle(color: Colors.white)),
          trailing: Text('${entry.value} pts', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildBracketTab() {
    // Simple bracket view, for now just list matches
    return ListView.builder(
      itemCount: widget.tournament.matches.length,
      itemBuilder: (context, index) {
        final match = widget.tournament.matches[index];
        final team1 = widget.tournament.teams.firstWhere((t) => t.id == match.team1Id);
        final team2 = widget.tournament.teams.firstWhere((t) => t.id == match.team2Id);
        return Card(
          color: Colors.grey[800],
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${team1.name} vs ${team2.name}', style: TextStyle(color: Colors.white)),
                if (match.isCompleted)
                  Text('${match.score1} - ${match.score2}', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTeam() {
    if (_teamNameController.text.isEmpty || widget.tournament.teams.length >= 8) return;

    setState(() {
      widget.tournament.addTeam(_teamNameController.text);
    });
    _teamNameController.clear();
    _saveTournament();
  }

  void _generateMatches() {
    setState(() {
      widget.tournament.generateMatches();
    });
    _saveTournament();
  }

  void _updateMatchScore(LocalMatch match, int score1, int score2) {
    setState(() {
      match.score1 = score1;
      match.score2 = score2;
      match.isCompleted = true;
      widget.tournament.updateStandings();
    });
    _saveTournament();
  }

  void _saveTournament() {
    context.read<LocalTournamentProvider>().updateTournament(widget.tournament);
  }
}