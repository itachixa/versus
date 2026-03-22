import 'dart:io';
import 'package:flutter/material.dart';
import '../models/local_tournament.dart';
import '../models/player_model.dart';
import '../models/local_team.dart';

class TournamentSummaryPage extends StatelessWidget {
  final LocalTournament tournament;
  final VoidCallback? onClose;

  const TournamentSummaryPage({
    super.key,
    required this.tournament,
    this.onClose,
  });

  List<Player> get allPlayers {
    final players = <Player>[];
    for (var team in tournament.teams) {
      players.addAll(team.players);
    }
    return players;
  }

  Player? get topScorer {
    final players = allPlayers;
    if (players.isEmpty) return null;
    return players.reduce((a, b) => a.totalPoints > b.totalPoints ? a : b);
  }

  Player? get mvp {
    final players = allPlayers;
    if (players.isEmpty) return null;
    
    int maxWins = 0;
    Player? mvpPlayer;
    
    for (var player in players) {
      if (player.wins > maxWins) {
        maxWins = player.wins;
        mvpPlayer = player;
      } else if (player.wins == maxWins && 
                 player.totalPoints > (mvpPlayer?.totalPoints ?? 0)) {
        mvpPlayer = player;
      }
    }
    return mvpPlayer;
  }

  LocalTeam? get bestTeam {
    if (tournament.teams.isEmpty) return null;
    return tournament.teams.reduce(
      (a, b) => a.totalPoints > b.totalPoints ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text('Tournament Summary'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
            onClose?.call();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTrophySection(),
            const SizedBox(height: 24),
            _buildAwardsSection(),
            const SizedBox(height: 24),
            _buildTournamentStats(),
            const SizedBox(height: 24),
            _buildFullLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.3),
            Colors.amber.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            tournament.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tournament.tournamentType == TournamentType.groupStage
                  ? 'GROUP STAGE CHAMPION'
                  : 'KNOCKOUT CHAMPION',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (bestTeam != null) ...[
            Text(
              bestTeam!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Best Team',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAwardsSection() {
    return Row(
      children: [
        Expanded(child: _buildMVPAward()),
        const SizedBox(width: 12),
        Expanded(child: _buildTopScorerAward()),
      ],
    );
  }

  Widget _buildMVPAward() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.purple,
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'MVP',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          if (mvp != null) ...[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueAccent,
              backgroundImage: mvp!.photoPath != null
                  ? FileImage(File(mvp!.photoPath!))
                  : null,
              child: mvp!.photoPath == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              mvp!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${mvp!.wins}W - ${mvp!.losses}L',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ] else
            const Text(
              '-',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildTopScorerAward() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.green.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_score,
            color: Colors.green,
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'TOP SCORER',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          if (topScorer != null) ...[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueAccent,
              backgroundImage: topScorer!.photoPath != null
                  ? FileImage(File(topScorer!.photoPath!))
                  : null,
              child: topScorer!.photoPath == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              topScorer!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${topScorer!.totalPoints} points',
              style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ] else
            const Text(
              '-',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentStats() {
    final totalMatches = tournament.matches.length;
    final completedMatches = tournament.matches.where((m) => m.isCompleted).length;
    final totalPlayers = allPlayers.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tournament Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Teams', tournament.teams.length.toString(), Icons.groups),
              _buildStatItem('Players', totalPlayers.toString(), Icons.person),
              _buildStatItem('Matches', '$completedMatches/$totalMatches', Icons.sports_score),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFullLeaderboard() {
    final players = List<Player>.from(allPlayers);
    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Full Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...players.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = entry.value;
            return _buildLeaderboardRow(player, rank);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(Player player, int rank) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey;
    } else if (rank == 3) {
      rankColor = Colors.brown;
    } else {
      rankColor = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3 ? rankColor.withOpacity(0.1) : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: rank <= 3 ? Border.all(color: rankColor) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            backgroundImage:
                player.photoPath != null ? FileImage(File(player.photoPath!)) : null,
            child: player.photoPath == null
                ? const Icon(Icons.person, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getTeamName(player),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.totalPoints} pts',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${player.wins}W - ${player.losses}L',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTeamName(Player player) {
    for (var team in tournament.teams) {
      if (team.players.any((p) => p.id == player.id)) {
        return team.name;
      }
    }
    return 'Unknown';
  }
}
