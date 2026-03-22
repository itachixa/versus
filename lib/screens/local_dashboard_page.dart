import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/local_tournament_provider.dart';
import 'create_local_tournament_page.dart';
import 'local_tournament_detail_page.dart';
import '../models/local_tournament.dart';
import 'tournament_summary_page.dart';

class LocalDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalTournamentProvider>().loadTournaments();
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.sports_esports, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('VERSUS', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF1a1a1a)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer<LocalTournamentProvider>(
            builder: (context, provider, child) {
              if (provider.tournaments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 64,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'No tournaments yet',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first tournament to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateLocalTournamentPage()),
                        ),
                        icon: Icon(Icons.add),
                        label: Text('Create Tournament'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: provider.tournaments.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateLocalTournamentPage()),
                        ),
                        icon: Icon(Icons.add),
                        label: Text('Create New Tournament'),
                      ),
                    );
                  }
                  final tournament = provider.tournaments[index - 1];
                  return _buildTournamentCard(context, tournament);
                },
              );
            },
          ),
        ),
      );
  }

  Widget _buildTournamentCard(BuildContext context, LocalTournament tournament) {
    final completedMatches = tournament.matches.where((m) => m.isCompleted).length;
    final totalMatches = tournament.matches.length;
    final isComplete = totalMatches > 0 && completedMatches == totalMatches;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [Colors.amber.withOpacity(0.2), Colors.amber.withOpacity(0.05)]
              : [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete ? Colors.amber : Colors.grey.shade700,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocalTournamentDetailPage(tournament: tournament),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tournament.tournamentType == TournamentType.groupStage
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tournament.tournamentType == TournamentType.groupStage
                            ? Icons.groups
                            : Icons.emoji_events,
                        color: tournament.tournamentType == TournamentType.groupStage
                            ? Colors.blue
                            : Colors.red,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tournament.tournamentType == TournamentType.groupStage
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tournament.tournamentType == TournamentType.groupStage
                                      ? 'GROUP'
                                      : 'KNOCKOUT',
                                  style: TextStyle(
                                    color: tournament.tournamentType == TournamentType.groupStage
                                        ? Colors.blue
                                        : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${tournament.teams.length} teams',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.emoji_events, color: Colors.black, size: 20),
                      )
                    else
                      Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalMatches > 0 ? completedMatches / totalMatches : 0,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isComplete ? Colors.amber : Colors.green,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '$completedMatches/$totalMatches',
                      style: TextStyle(
                        color: isComplete ? Colors.amber : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}