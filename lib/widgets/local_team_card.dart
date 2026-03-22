import 'dart:io';
import 'package:flutter/material.dart';
import '../models/local_team.dart';
import '../models/player_model.dart';

class LocalTeamCard extends StatelessWidget {
  final LocalTeam team;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLeading;

  const LocalTeamCard({
    required this.team,
    this.onTap,
    this.isSelected = false,
    this.isLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLeading
                ? [Color(0xFF1a472a), Color(0xFF2d5a3d)]
                : isSelected
                    ? [Color(0xFF1a2a4a), Color(0xFF2d4a6a)]
                    : [Color(0xFF2a2a2a), Color(0xFF1a1a1a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLeading
                ? Colors.green
                : isSelected
                    ? Colors.blue
                    : Colors.grey.shade700,
            width: 2,
          ),
          boxShadow: isSelected || isLeading
              ? [
                  BoxShadow(
                    color: (isLeading ? Colors.green : Colors.blue).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isLeading)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'LEADING',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              if (team.players.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: team.players.map((player) => _buildPlayerChip(player)).toList(),
                ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip('W', team.wins.toString(), Colors.green),
                  SizedBox(width: 8),
                  _buildStatChip('L', team.losses.toString(), Colors.red),
                  SizedBox(width: 8),
                  _buildStatChip('D', team.draws.toString(), Colors.grey),
                  SizedBox(width: 8),
                  _buildStatChip('PTS', team.totalPoints.toString(), Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerChip(Player player) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blueAccent,
            backgroundImage: player.photoPath != null ? FileImage(File(player.photoPath!)) : null,
            child: player.photoPath == null
                ? Icon(Icons.person, size: 14, color: Colors.white)
                : null,
          ),
          SizedBox(width: 6),
          Text(
            player.name,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(width: 4),
          Text(
            '${player.totalPoints}',
            style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
