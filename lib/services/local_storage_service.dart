import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_tournament.dart';

class LocalStorageService {
  static const String tournamentsKey = 'tournaments';

  static Future<void> init() async {
    // No init needed for SharedPreferences
  }

  static Future<void> saveTournament(LocalTournament tournament) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tournamentsJson = prefs.getStringList(tournamentsKey) ?? [];
    
    // Remove existing if updating
    tournamentsJson.removeWhere((json) {
      Map<String, dynamic> t = jsonDecode(json);
      return t['id'] == tournament.id;
    });
    
    // Add new
    tournamentsJson.add(jsonEncode(tournament.toJson()));
    await prefs.setStringList(tournamentsKey, tournamentsJson);
  }

  static Future<LocalTournament?> getTournament(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tournamentsJson = prefs.getStringList(tournamentsKey) ?? [];
    
    for (String json in tournamentsJson) {
      Map<String, dynamic> t = jsonDecode(json);
      if (t['id'] == id) {
        return LocalTournament.fromJson(t);
      }
    }
    return null;
  }

  static Future<List<LocalTournament>> getAllTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tournamentsJson = prefs.getStringList(tournamentsKey) ?? [];
    
    return tournamentsJson.map((json) => LocalTournament.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> deleteTournament(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tournamentsJson = prefs.getStringList(tournamentsKey) ?? [];
    
    tournamentsJson.removeWhere((json) {
      Map<String, dynamic> t = jsonDecode(json);
      return t['id'] == id;
    });
    
    await prefs.setStringList(tournamentsKey, tournamentsJson);
  }
}