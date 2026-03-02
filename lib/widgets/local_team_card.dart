import 'package:flutter/material.dart';
import '../models/local_team.dart';

class LocalTeamCard extends StatelessWidget {
  final LocalTeam team;

  LocalTeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (team.players.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: team.players.map((player) => Text(
                  player,
                  style: TextStyle(color: Colors.grey),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}