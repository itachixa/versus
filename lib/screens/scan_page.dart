import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'online_tournament_detail_page.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController teamController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join with QR"), backgroundColor: Colors.black),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null) {
                      _joinTournament(code);
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: teamController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Team Name',
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
          ],
        ),
      ),
    );
  }

  void _joinTournament(String tournamentId) async {
    if (teamController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("teams").add({
      "name": teamController.text,
      "tournamentId": tournamentId,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineTournamentDetailPage(tournamentId: tournamentId),
      ),
    );
  }
}