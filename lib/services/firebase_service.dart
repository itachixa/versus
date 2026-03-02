import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament_model.dart';
import '../models/match_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tournaments
  Future<String> createTournament(String name, {String? createdBy}) async {
    try {
      String id = _generateId();
      await _firestore.collection('tournaments').doc(id).set({
        'name': name,
        'createdAt': Timestamp.now(),
        'createdBy': createdBy,
      });
      return id;
    } catch (e) {
      throw Exception('Failed to create tournament: $e');
    }
  }
  
  Future<void> updateTournamentMode(String id, TournamentMode mode, int? teamSize) async {
    await _firestore.collection('tournaments').doc(id).update({
      'mode': mode.index,
      'teamSize': teamSize,
    });
  }

  Future<Tournament?> getTournament(String id) async {
    DocumentSnapshot doc = await _firestore.collection('tournaments').doc(id).get();
    if (doc.exists) {
      return Tournament.fromMap(id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Teams
  Future<void> addTeam(String tournamentId, String teamName) async {
    await _firestore.collection('teams').add({
      'name': teamName,
      'tournamentId': tournamentId,
    });
  }

  Stream<QuerySnapshot> getTeams(String tournamentId) {
    return _firestore
        .collection('teams')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots();
  }

  // Matches
  Future<void> createMatch(Match match) async {
    await _firestore.collection('matches').doc(match.id).set(match.toMap());
  }

  Future<void> updateMatchScore(String matchId, int scoreA, int scoreB) async {
    await _firestore.collection('matches').doc(matchId).update({
      'scoreA': scoreA,
      'scoreB': scoreB,
    });
  }

  Stream<QuerySnapshot> getMatches(String tournamentId) {
    return _firestore
        .collection('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots();
  }

  String _generateId() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }
}