import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_tournament.dart';
import '../providers/local_tournament_provider.dart';
import 'local_tournament_detail_page.dart';
import 'dart:math';

class CreateLocalTournamentPage extends StatefulWidget {
  @override
  _CreateLocalTournamentPageState createState() => _CreateLocalTournamentPageState();
}

class _CreateLocalTournamentPageState extends State<CreateLocalTournamentPage> {
  final _nameController = TextEditingController();
  int _matchType = 1; // 1v1
  int _timerMinutes = 5;

  String _generateId() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Local Tournament'),
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tournament Name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Match Type:', style: TextStyle(color: Colors.white, fontSize: 16)),
            DropdownButton<int>(
              value: _matchType,
              dropdownColor: Colors.grey[800],
              style: TextStyle(color: Colors.white),
              items: [
                DropdownMenuItem(value: 1, child: Text('1 vs 1')),
                DropdownMenuItem(value: 2, child: Text('2 vs 2')),
                DropdownMenuItem(value: 3, child: Text('3 vs 3')),
                DropdownMenuItem(value: 4, child: Text('4 vs 4')),
                DropdownMenuItem(value: 5, child: Text('5 vs 5')),
              ],
              onChanged: (value) => setState(() => _matchType = value!),
            ),
            SizedBox(height: 20),
            Text('Timer per Match:', style: TextStyle(color: Colors.white, fontSize: 16)),
            DropdownButton<int>(
              value: _timerMinutes,
              dropdownColor: Colors.grey[800],
              style: TextStyle(color: Colors.white),
              items: [
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
              ],
              onChanged: (value) => setState(() => _timerMinutes = value!),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: _createTournament,
                child: Text('Create Tournament'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTournament() async {
    if (_nameController.text.isEmpty) return;

    final tournament = LocalTournament(
      id: _generateId(),
      name: _nameController.text,
      createdAt: DateTime.now(),
      matchType: _matchType,
      timerMinutes: _timerMinutes,
      teams: [],
      matches: [],
      standings: {},
    );

    await context.read<LocalTournamentProvider>().addTournament(tournament);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LocalTournamentDetailPage(tournament: tournament),
      ),
    );
  }
}