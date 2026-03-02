import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'online_tournament_detail_page.dart';
import 'dart:math';

class CreateOnlineTournamentPage extends StatefulWidget {
  @override
  _CreateOnlineTournamentPageState createState() => _CreateOnlineTournamentPageState();
}

class _CreateOnlineTournamentPageState extends State<CreateOnlineTournamentPage> {
  final _nameController = TextEditingController();

  String _generateId() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un tournoi en ligne'),
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
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nom du tournoi',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _createTournament,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Créer le tournoi'),
            ),
          ],
        ),
      ),
    );
  }

  void _createTournament() async {
    if (_nameController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final id = _generateId();

    await FirebaseFirestore.instance.collection('tournaments').doc(id).set({
      'name': _nameController.text,
      'creatorId': user?.uid,
      'createdAt': Timestamp.now(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineTournamentDetailPage(tournamentId: id),
      ),
    );
  }
}