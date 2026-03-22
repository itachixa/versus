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
  int _matchType = 1;
  int _timerMinutes = 5;
  TournamentType _tournamentType = TournamentType.knockout;

  String _generateId() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Create Tournament'),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
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
                    borderSide: BorderSide(color: Colors.grey.shade600),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Tournament Type',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTournamentTypeCard(
                    type: TournamentType.groupStage,
                    title: 'Group Stage',
                    subtitle: 'Pools with round-robin',
                    icon: Icons.groups,
                    color: Colors.blue,
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _buildTournamentTypeCard(
                    type: TournamentType.knockout,
                    title: 'Knockout',
                    subtitle: 'Direct elimination',
                    icon: Icons.emoji_events,
                    color: Colors.red,
                  )),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Players per Team',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: DropdownButton<int>(
                  value: _matchType,
                  isExpanded: true,
                  dropdownColor: Colors.grey.shade800,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('1 vs 1 (Solo)')),
                    DropdownMenuItem(value: 2, child: Text('2 vs 2 (Doubles)')),
                    DropdownMenuItem(value: 3, child: Text('3 vs 3')),
                    DropdownMenuItem(value: 4, child: Text('4 vs 4')),
                    DropdownMenuItem(value: 5, child: Text('5 vs 5 (Full Team)')),
                  ],
                  onChanged: (value) => setState(() => _matchType = value!),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Match Duration',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: DropdownButton<int>(
                  value: _timerMinutes,
                  isExpanded: true,
                  dropdownColor: Colors.grey.shade800,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  items: [
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 20, child: Text('20 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  ],
                  onChanged: (value) => setState(() => _timerMinutes = value!),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _createTournament,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 8),
                      Text('Create Tournament', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentTypeCard({
    required TournamentType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _tournamentType == type;

    return GestureDetector(
      onTap: () => setState(() => _tournamentType = type),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              SizedBox(height: 8),
              Icon(Icons.check_circle, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  void _createTournament() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a tournament name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tournament = LocalTournament(
      id: _generateId(),
      name: _nameController.text,
      createdAt: DateTime.now(),
      matchType: _matchType,
      timerMinutes: _timerMinutes,
      teams: [],
      matches: [],
      standings: {},
      tournamentType: _tournamentType,
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