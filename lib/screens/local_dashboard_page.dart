import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/local_tournament_provider.dart';
import 'create_local_tournament_page.dart';
import 'local_tournament_detail_page.dart';

class LocalDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Load tournaments when entering the dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalTournamentProvider>().loadTournaments();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Local Tournaments'),
        backgroundColor: Colors.black,
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey[900]!],
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
                      Text(
                        'No local tournaments',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateLocalTournamentPage()),
                        ),
                        child: Text('Create Tournament'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: provider.tournaments.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateLocalTournamentPage()),
                        ),
                        child: Text('Create New Tournament'),
                      ),
                    );
                  }
                  final tournament = provider.tournaments[index - 1];
                  return Card(
                    color: Colors.grey[800],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        tournament.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${tournament.teams.length} teams • ${tournament.matches.where((m) => m.isCompleted).length}/${tournament.matches.length} matches',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocalTournamentDetailPage(tournament: tournament),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
  }
}