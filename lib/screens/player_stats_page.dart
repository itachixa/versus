import 'dart:io';
import 'package:flutter/material.dart';
import '../models/local_tournament.dart';
import '../models/player_model.dart';

class PlayerStatsPage extends StatefulWidget {
  final LocalTournament tournament;

  const PlayerStatsPage({super.key, required this.tournament});

  @override
  State<PlayerStatsPage> createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Player> get allPlayers {
    final players = <Player>[];
    for (var team in widget.tournament.teams) {
      players.addAll(team.players);
    }
    return players;
  }

  Player? get topScorer {
    final players = allPlayers;
    if (players.isEmpty) return null;
    return players.reduce((a, b) => a.totalPoints > b.totalPoints ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryCards(),
        Container(
          color: Colors.grey.shade900,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Leaderboard'),
              Tab(text: 'All Players'),
            ],
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardTab(),
              _buildAllPlayersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final players = allPlayers;
    final mvp = _getMVP();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Players',
              value: players.length.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Top Scorer',
              value: topScorer?.name ?? '-',
              icon: Icons.emoji_events,
              color: Colors.amber,
              subtitle: topScorer != null ? '${topScorer!.totalPoints} pts' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'MVP',
              value: mvp?.name ?? '-',
              icon: Icons.star,
              color: Colors.purple,
              subtitle: mvp != null ? '${mvp.totalPoints} pts' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final players = List<Player>.from(allPlayers);
    if (players.isEmpty) {
      return _buildEmptyState();
    }

    players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final rank = index + 1;
        final team = _getPlayerTeam(player);

        return _buildLeaderboardCard(player, rank, team);
      },
    );
  }

  Widget _buildAllPlayersTab() {
    final teams = widget.tournament.teams;

    if (teams.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamSection(team);
      },
    );
  }

  Widget _buildTeamSection(team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.groups, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${team.totalPoints} pts',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (team.players.isEmpty)
            const Text(
              'No players',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...team.players.map((player) => _buildPlayerRow(player, team)),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(Player player, team) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueAccent,
            backgroundImage:
                player.photoPath != null ? FileImage(File(player.photoPath!)) : null,
            child: player.photoPath == null
                ? Icon(Icons.person, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _buildMiniStat('PTS', player.totalPoints.toString(), Colors.green),
          const SizedBox(width: 8),
          _buildMiniStat('W', player.wins.toString(), Colors.blue),
          const SizedBox(width: 8),
          _buildMiniStat('L', player.losses.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(Player player, int rank, team) {
    Color rankColor;
    IconData? rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey;
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = Colors.brown;
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Colors.grey.shade600;
        rankIcon = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: rank <= 3
            ? LinearGradient(
                colors: [rankColor.withOpacity(0.2), rankColor.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: rank <= 3 ? null : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? rankColor : Colors.grey.shade800,
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, color: Colors.white, size: 20)
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueAccent,
            backgroundImage:
                player.photoPath != null ? FileImage(File(player.photoPath!)) : null,
            child: player.photoPath == null
                ? Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  team?.name ?? 'Unknown',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.green, size: 16),
                  Text(
                    '${player.totalPoints}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${player.matchesPlayed} matches',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_score, color: Colors.grey.shade600, size: 64),
          const SizedBox(height: 16),
          Text(
            'No players yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Add players to see statistics',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Player? _getMVP() {
    final players = allPlayers;
    if (players.isEmpty) return null;

    int maxWins = 0;
    Player? mvp;

    for (var player in players) {
      if (player.wins > maxWins) {
        maxWins = player.wins;
        mvp = player;
      } else if (player.wins == maxWins && player.totalPoints > (mvp?.totalPoints ?? 0)) {
        mvp = player;
      }
    }

    return mvp;
  }

  dynamic _getPlayerTeam(Player player) {
    for (var team in widget.tournament.teams) {
      if (team.players.any((p) => p.id == player.id)) {
        return team;
      }
    }
    return null;
  }
}
