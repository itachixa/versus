import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'match_page.dart';
import '../widgets/team_card.dart';
import '../services/match_generator.dart';

class TournamentPage extends StatelessWidget {
  final String tournamentId;

  TournamentPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tournament $tournamentId")),
      body: Column(
        children: [
          SizedBox(height: 20),
          QrImageView(data: tournamentId, size: 200),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("teams")
                  .where("tournamentId", isEqualTo: tournamentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var teams = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (_, index) {
                    return TeamCard(
                      teamName: teams[index]["name"],
                      onTap: () {
                        // Navigate to match or something
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}