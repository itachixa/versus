import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Function(int) onAddPoints;

  ScoreCard({
    required this.teamName,
    required this.score,
    required this.onAddPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(teamName, style: TextStyle(fontSize: 20)),
        Text("$score", style: TextStyle(fontSize: 60)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => onAddPoints(1), child: Text("+1")),
            SizedBox(width: 10),
            ElevatedButton(onPressed: () => onAddPoints(2), child: Text("+2")),
            SizedBox(width: 10),
            ElevatedButton(onPressed: () => onAddPoints(3), child: Text("+3")),
          ],
        ),
      ],
    );
  }
}