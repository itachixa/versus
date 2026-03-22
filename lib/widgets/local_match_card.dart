import 'package:flutter/material.dart';
import '../models/local_match.dart';
import '../models/local_tournament.dart';

class LocalMatchCard extends StatefulWidget {
  final LocalMatch match;
  final Function(LocalMatch, int, int) onScoreUpdate;
  final LocalTournament tournament;
  final VoidCallback? onTap;

  const LocalMatchCard({
    required this.match,
    required this.onScoreUpdate,
    required this.tournament,
    this.onTap,
  });

  @override
  _LocalMatchCardState createState() => _LocalMatchCardState();
}

class _LocalMatchCardState extends State<LocalMatchCard> with SingleTickerProviderStateMixin {
  late TextEditingController _score1Controller;
  late TextEditingController _score2Controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _score1Controller = TextEditingController(text: widget.match.score1.toString());
    _score2Controller = TextEditingController(text: widget.match.score2.toString());
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _score1Controller.dispose();
    _score2Controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team1 = widget.tournament.teams.firstWhere(
      (t) => t.id == widget.match.team1Id,
      orElse: () => widget.tournament.teams.first,
    );
    final team2 = widget.tournament.teams.firstWhere(
      (t) => t.id == widget.match.team2Id,
      orElse: () => widget.tournament.teams.first,
    );

    final isKnockout = widget.match.matchType == MatchType.knockout || widget.match.matchType == MatchType.final_;
    final statusColor = widget.match.isCompleted
        ? Colors.green
        : widget.match.status == MatchStatus.inProgress
            ? Colors.orange
            : Colors.grey;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMatchTypeChip(),
                  if (widget.match.round > 0)
                    Text(
                      'Round ${widget.match.round}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTeamSection(team1.name, team1.totalPoints, true)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.match.score1} - ${widget.match.score2}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.match.isCompleted && widget.match.winnerId != null)
                          Icon(
                            widget.match.winnerId == widget.match.team1Id
                                ? Icons.emoji_events
                                : Icons.emoji_events_outlined,
                            color: Colors.amber,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildTeamSection(team2.name, team2.totalPoints, false)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _score1Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _score2Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitScore,
                  icon: Icon(widget.match.isCompleted ? Icons.update : Icons.save),
                  label: Text(widget.match.isCompleted ? 'Update Score' : 'Save Score'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.match.isCompleted ? Colors.orange : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTypeChip() {
    String label;
    Color color;
    switch (widget.match.matchType) {
      case MatchType.groupStage:
        label = 'GROUP';
        color = Colors.blue;
        break;
      case MatchType.knockout:
        label = 'KNOCKOUT';
        color = Colors.red;
        break;
      case MatchType.final_:
        label = 'FINAL';
        color = Colors.amber;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTeamSection(String teamName, int points, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          teamName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        ),
        SizedBox(height: 4),
        Text(
          '$points pts',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _submitScore() {
    final score1 = int.tryParse(_score1Controller.text) ?? 0;
    final score2 = int.tryParse(_score2Controller.text) ?? 0;
    _animationController.forward().then((_) => _animationController.reverse());
    widget.onScoreUpdate(widget.match, score1, score2);
  }
}
