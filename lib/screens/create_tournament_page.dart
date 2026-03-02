import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_page.dart';
import 'dart:math';

class CreateTournamentPage extends StatelessWidget {

  final TextEditingController controller = TextEditingController();

  String generateId() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Tournament")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Tournament Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Create"),
              onPressed: () async {
                String id = generateId();
                await FirebaseFirestore.instance.collection("tournaments").doc(id).set({
                  "name": controller.text,
                  "createdAt": Timestamp.now(),
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TournamentPage(tournamentId: id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}