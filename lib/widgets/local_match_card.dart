import 'package:flutter/material.dart';
import '../models/local_match.dart';
import '../models/local_tournament.dart';

class LocalMatchCard extends StatefulWidget {
  final LocalMatch match;
  final Function(LocalMatch, int, int) onScoreUpdate;
  final LocalTournament tournament;

  LocalMatchCard({required this.match, required this.onScoreUpdate, required this.tournament});

  @override
  _LocalMatchCardState createState() => _LocalMatchCardState();
}

class _LocalMatchCardState extends State<LocalMatchCard> {
  late TextEditingController _score1Controller;
  late TextEditingController _score2Controller;

  @override
  void initState() {
    super.initState();
    _score1Controller = TextEditingController(text: widget.match.score1.toString());
    _score2Controller = TextEditingController(text: widget.match.score2.toString());
  }

  @override
  Widget build(BuildContext context) {
    final team1 = widget.tournament.teams.firstWhere((t) => t.id == widget.match.team1Id);
    final team2 = widget.tournament.teams.firstWhere((t) => t.id == widget.match.team2Id);

    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${team1.name} vs ${team2.name}',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreInput(team1.name, _score1Controller),
                Text(' - ', style: TextStyle(color: Colors.white, fontSize: 24)),
                _buildScoreInput(team2.name, _score2Controller),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitScore,
              child: Text(widget.match.isCompleted ? 'Modifier le score' : 'Enregistrer le score'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.match.isCompleted ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreInput(String teamName, TextEditingController controller) {
    return Column(
      children: [
        Text(teamName, style: TextStyle(color: Colors.white)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitScore() {
    final score1 = int.tryParse(_score1Controller.text) ?? 0;
    final score2 = int.tryParse(_score2Controller.text) ?? 0;
    widget.onScoreUpdate(widget.match, score1, score2);
  }
}