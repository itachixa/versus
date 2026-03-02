import 'package:flutter/material.dart';
import '../models/local_tournament.dart';
import '../services/local_storage_service.dart';

class LocalTournamentProvider with ChangeNotifier {
  List<LocalTournament> _tournaments = [];

  List<LocalTournament> get tournaments => _tournaments;

  Future<void> loadTournaments() async {
    _tournaments = await LocalStorageService.getAllTournaments();
    notifyListeners();
  }

  Future<void> addTournament(LocalTournament tournament) async {
    await LocalStorageService.saveTournament(tournament);
    _tournaments.add(tournament);
    notifyListeners();
  }

  Future<void> updateTournament(LocalTournament tournament) async {
    await LocalStorageService.saveTournament(tournament);
    final index = _tournaments.indexWhere((t) => t.id == tournament.id);
    if (index != -1) {
      _tournaments[index] = tournament;
      notifyListeners();
    }
  }

  Future<void> deleteTournament(String id) async {
    await LocalStorageService.deleteTournament(id);
    _tournaments.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}