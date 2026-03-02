import 'package:cloud_firestore/cloud_firestore.dart';

enum TournamentMode { oneVsOne, team }

class Tournament {
  final String id;
  final String name;
  final DateTime createdAt;
  final TournamentMode? mode;
  final int? teamSize; // null for 1v1, otherwise 3,4,5 for team mode

  Tournament({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.mode,
    this.teamSize,
  });

  factory Tournament.fromMap(String id, Map<String, dynamic> data) {
    return Tournament(
      id: id,
      name: data['name'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      mode: data['mode'] != null ? TournamentMode.values[data['mode']] : null,
      teamSize: data['teamSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'mode': mode?.index,
      'teamSize': teamSize,
    };
  }
}