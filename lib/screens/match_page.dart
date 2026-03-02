import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/score_card.dart';

class MatchPage extends StatefulWidget {
  final String teamA;
  final String teamB;

  MatchPage({required this.teamA, required this.teamB});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {

  int scoreA = 0;
  int scoreB = 0;
  int seconds = 600;
  Timer? timer;
  final player = AudioPlayer();

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
        player.play(AssetSource('sounds/buzzer.mp3'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String min = (seconds ~/ 60).toString().padLeft(2, '0');
    String sec = (seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text("${widget.teamA} vs ${widget.teamB}")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$min:$sec", style: TextStyle(fontSize: 40)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScoreCard(
                teamName: widget.teamA,
                score: scoreA,
                onAddPoints: (p) => setState(() => scoreA += p),
              ),
              ScoreCard(
                teamName: widget.teamB,
                score: scoreB,
                onAddPoints: (p) => setState(() => scoreB += p),
              ),
            ],
          ),
          ElevatedButton(onPressed: startTimer, child: Text("Start")),
        ],
      ),
    );
  }

}