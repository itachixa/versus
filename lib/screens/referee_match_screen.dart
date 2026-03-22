import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/local_match.dart';
import '../models/local_team.dart';
import '../models/player_model.dart';
import '../models/local_tournament.dart';
import '../services/sound_service.dart';

class _ScoringAction {
  final String playerId;
  final int points;
  final bool isTeam1;
  final DateTime timestamp;

  _ScoringAction({
    required this.playerId,
    required this.points,
    required this.isTeam1,
    required this.timestamp,
  });
}

class RefereeMatchScreen extends StatefulWidget {
  final LocalMatch match;
  final LocalTournament tournament;
  final Function(LocalMatch) onMatchUpdate;

  const RefereeMatchScreen({
    required this.match,
    required this.tournament,
    required this.onMatchUpdate,
  });

  @override
  _RefereeMatchScreenState createState() => _RefereeMatchScreenState();
}

class _RefereeMatchScreenState extends State<RefereeMatchScreen>
    with TickerProviderStateMixin {
  String? selectedPlayerId;
  bool isTeam1Selected = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  final ImagePicker _imagePicker = ImagePicker();
  final SoundService _soundService = SoundService();
  bool _isScoreAnimating = false;

  final List<_ScoringAction> _scoringHistory = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scoreAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  LocalTeam get team1 => widget.tournament.teams.firstWhere(
        (t) => t.id == widget.match.team1Id,
        orElse: () => widget.tournament.teams.first,
      );

  LocalTeam get team2 => widget.tournament.teams.firstWhere(
        (t) => t.id == widget.match.team2Id,
        orElse: () => widget.tournament.teams.first,
      );

  int get team1TotalPoints => team1.players.fold(
      0, (sum, player) => sum + (widget.match.player1Points[player.id] ?? 0));

  int get team2TotalPoints => team2.players.fold(
      0, (sum, player) => sum + (widget.match.player2Points[player.id] ?? 0));

  @override
  Widget build(BuildContext context) {
    final isLeadingTeam1 = team1TotalPoints > team2TotalPoints;
    final isTied = team1TotalPoints == team2TotalPoints;

    return Scaffold(
      backgroundColor: Color(0xFF0a0a0a),
      appBar: AppBar(
        title: Row(
          children: [
            _buildMatchTypeChip(),
            SizedBox(width: 8),
            Text('Round ${widget.match.round}'),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreBoard(isLeadingTeam1, isTied),
            SizedBox(height: 24),
            _buildTeamSection(team1, true, !isLeadingTeam1 && !isTied),
            SizedBox(height: 24),
            _buildTeamSection(team2, false, isLeadingTeam1),
            SizedBox(height: 24),
            _buildMatchControls(),
          ],
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildScoreBoard(bool isLeadingTeam1, bool isTied) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTied ? Colors.grey : (isLeadingTeam1 ? Colors.blue : Colors.red),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTied ? Colors.grey : (isLeadingTeam1 ? Colors.blue : Colors.red))
                .withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: !isTied && isLeadingTeam1 ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: AnimatedBuilder(
              animation: _scoreScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scoreScaleAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    team1TotalPoints.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    team1.name,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: !isTied && !isLeadingTeam1 ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: AnimatedBuilder(
              animation: _scoreScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scoreScaleAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    team2TotalPoints.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    team2.name,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(LocalTeam team, bool isTeam1, bool isLeading) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeading
              ? [Color(0xFF1a3a1a), Color(0xFF2d5a2d)]
              : [Color(0xFF2a2a2a), Color(0xFF1a1a1a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLeading ? Colors.green : Colors.grey.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isTeam1 ? Icons.sports_basketball : Icons.sports_basketball_outlined,
                    color: isTeam1 ? Colors.blue : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    team.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          if (team.players.isEmpty)
            _buildAddPlayerButton(team, isTeam1)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...team.players.map((player) => _buildPlayerCard(
                      player,
                      isTeam1,
                      isLeading,
                    )),
                _buildAddPlayerButton(team, isTeam1),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, bool isTeam1, bool isLeading) {
    final points = isTeam1
        ? (widget.match.player1Points[player.id] ?? 0)
        : (widget.match.player2Points[player.id] ?? 0);
    final isSelected = selectedPlayerId == player.id && isTeam1Selected == isTeam1;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlayerId = player.id;
          isTeam1Selected = isTeam1;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color(0xFF1a4a8a), Color(0xFF2d6aaa)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade600,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueAccent,
                  backgroundImage:
                      player.photoPath != null ? FileImage(File(player.photoPath!)) : null,
                  child: player.photoPath == null
                      ? Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () => _changePlayerPhoto(player),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(Icons.camera_alt, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              player.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLeading ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 14),
                  SizedBox(width: 2),
                  Text(
                    points.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPlayerButton(LocalTeam team, bool isTeam1) {
    return GestureDetector(
      onTap: () => _showAddPlayerDialog(team, isTeam1),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'Add Player',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchControls() {
    final hasSelectedPlayer = selectedPlayerId != null;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (!hasSelectedPlayer)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tap a player to select, then score',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selected: ${_getSelectedPlayerName()}',
                        style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreButton(1, Colors.green, hasSelectedPlayer),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildScoreButton(2, Colors.blue, hasSelectedPlayer),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildScoreButton(3, Colors.red, hasSelectedPlayer),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleMatchStatus,
                icon: Icon(widget.match.status == MatchStatus.inProgress
                    ? Icons.pause
                    : Icons.play_arrow),
                label: Text(widget.match.status == MatchStatus.inProgress
                    ? 'Pause'
                    : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.match.status == MatchStatus.inProgress
                      ? Colors.orange
                      : Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: _scoringHistory.isEmpty ? null : _undoLastAction,
                icon: Icon(Icons.undo, color: _scoringHistory.isEmpty ? Colors.grey : Colors.white, size: 20),
                label: Text('Undo', style: TextStyle(fontSize: 12, color: _scoringHistory.isEmpty ? Colors.grey : Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _scoringHistory.isEmpty ? Colors.grey.shade800 : Colors.blueGrey,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _finishMatch,
                icon: Icon(Icons.flag, size: 20),
                label: Text('Finish', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreButton(int points, Color color, bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => _updatePlayerPoints(points) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? color : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '+$points',
            style: TextStyle(
              color: enabled ? Colors.white : Colors.grey.shade500,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getSelectedPlayerName() {
    if (selectedPlayerId == null) return '';
    final player = isTeam1Selected
        ? team1.players.firstWhere((p) => p.id == selectedPlayerId,
            orElse: () => Player(id: '', name: 'Unknown'))
        : team2.players.firstWhere((p) => p.id == selectedPlayerId,
            orElse: () => Player(id: '', name: 'Unknown'));
    return player.name;
  }

  void _updatePlayerPoints(int delta, [Player? player, bool? isTeam1Arg]) {
    final oldScore1 = team1TotalPoints;
    final oldScore2 = team2TotalPoints;

    final isTeam1 = isTeam1Arg ?? isTeam1Selected;
    final playerId = player?.id ?? selectedPlayerId;
    
    if (playerId == null) return;

    setState(() {
      if (isTeam1) {
        final currentPoints = widget.match.player1Points[playerId] ?? 0;
        widget.match.player1Points[playerId] = currentPoints + delta;
        if (widget.match.player1Points[playerId]! < 0) {
          widget.match.player1Points[playerId] = 0;
        }
      } else {
        final currentPoints = widget.match.player2Points[playerId] ?? 0;
        widget.match.player2Points[playerId] = currentPoints + delta;
        if (widget.match.player2Points[playerId]! < 0) {
          widget.match.player2Points[playerId] = 0;
        }
      }

      if (delta > 0) {
        _scoringHistory.add(_ScoringAction(
          playerId: playerId,
          points: delta,
          isTeam1: isTeam1,
          timestamp: DateTime.now(),
        ));
      }

      widget.match.score1 = team1TotalPoints;
      widget.match.score2 = team2TotalPoints;

      if (oldScore1 != team1TotalPoints || oldScore2 != team2TotalPoints) {
        _triggerScoreAnimation();
      }
    });

    HapticFeedback.mediumImpact();
    if (delta > 0) {
      _soundService.playPointUp();
    } else {
      _soundService.playPointDown();
    }
    widget.onMatchUpdate(widget.match);
  }

  void _undoLastAction() {
    if (_scoringHistory.isEmpty) return;

    final lastAction = _scoringHistory.removeLast();
    
    setState(() {
      if (lastAction.isTeam1) {
        final currentPoints = widget.match.player1Points[lastAction.playerId] ?? 0;
        widget.match.player1Points[lastAction.playerId] = 
          (currentPoints - lastAction.points).clamp(0, 999999);
      } else {
        final currentPoints = widget.match.player2Points[lastAction.playerId] ?? 0;
        widget.match.player2Points[lastAction.playerId] = 
          (currentPoints - lastAction.points).clamp(0, 999999);
      }
      
      widget.match.score1 = team1TotalPoints;
      widget.match.score2 = team2TotalPoints;
      _triggerScoreAnimation();
    });

    HapticFeedback.lightImpact();
    widget.onMatchUpdate(widget.match);
  }

  void _triggerScoreAnimation() async {
    if (_isScoreAnimating) return;
    _isScoreAnimating = true;
    await _scoreAnimationController.forward(from: 0);
    _isScoreAnimating = false;
  }

  void _toggleMatchStatus() {
    setState(() {
      widget.match.status = widget.match.status == MatchStatus.inProgress
          ? MatchStatus.pending
          : MatchStatus.inProgress;
    });
    widget.onMatchUpdate(widget.match);
    HapticFeedback.heavyImpact();
    if (widget.match.status == MatchStatus.inProgress) {
      _soundService.playMatchStart();
    }
  }

  void _finishMatch() {
    setState(() {
      widget.match.isCompleted = true;
      widget.match.status = MatchStatus.completed;
      widget.match.winnerId = widget.match.score1 > widget.match.score2
          ? widget.match.team1Id
          : widget.match.score2 > widget.match.score1
              ? widget.match.team2Id
              : null;

      for (var player in team1.players) {
        player.totalPoints += widget.match.player1Points[player.id] ?? 0;
        player.matchesPlayed++;
        if (widget.match.winnerId == widget.match.team1Id) {
          player.wins++;
        } else if (widget.match.winnerId == widget.match.team2Id) {
          player.losses++;
        }
      }

      for (var player in team2.players) {
        player.totalPoints += widget.match.player2Points[player.id] ?? 0;
        player.matchesPlayed++;
        if (widget.match.winnerId == widget.match.team2Id) {
          player.wins++;
        } else if (widget.match.winnerId == widget.match.team1Id) {
          player.losses++;
        }
      }

      widget.tournament.updateStandings();
      widget.tournament.advanceWinners();
    });

    widget.onMatchUpdate(widget.match);
    HapticFeedback.heavyImpact();
    _soundService.playMatchEnd();
    _showMatchSummary();
  }

  void _showMatchSummary() {
    final mvp = _getMVP();
    final winner = widget.match.winnerId != null
        ? (widget.match.winnerId == widget.match.team1Id ? team1 : team2)
        : null;

    if (mvp != null) {
      _soundService.playMVP();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1a2e),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Match Complete!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (winner != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Winner: ${winner.name}',
                      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            if (mvp != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.3), Colors.amber.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'MOST VALUABLE PLAYER',
                      style: TextStyle(
                        color: Colors.amber, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mvp.name,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_getMatchPlayerPoints(mvp)} points in this match',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(team1.name, style: TextStyle(color: Colors.white, fontSize: 12)),
                      Text(
                        '${team1TotalPoints}', 
                        style: TextStyle(
                          color: widget.match.winnerId == widget.match.team1Id 
                              ? Colors.green : Colors.white, 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('points', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade600,
                  ),
                  Column(
                    children: [
                      Text(team2.name, style: TextStyle(color: Colors.white, fontSize: 12)),
                      Text(
                        '${team2TotalPoints}', 
                        style: TextStyle(
                          color: widget.match.winnerId == widget.match.team2Id 
                              ? Colors.green : Colors.white, 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('points', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Continue', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  int _getMatchPlayerPoints(Player player) {
    if (widget.match.team1Id == team1.id) {
      return widget.match.player1Points[player.id] ?? 0;
    } else {
      return widget.match.player2Points[player.id] ?? 0;
    }
  }

  Player? _getMVP() {
    final allPlayers = [...team1.players, ...team2.players];
    if (allPlayers.isEmpty) return null;

    Player mvp = allPlayers.first;
    for (var player in allPlayers) {
      final playerPoints = (widget.match.team1Id == team1.id
              ? widget.match.player1Points[player.id]
              : widget.match.player2Points[player.id]) ??
          0;
      final mvpPoints = (widget.match.team1Id == team1.id
              ? widget.match.player1Points[mvp.id]
              : widget.match.player2Points[mvp.id]) ??
          0;
      if (playerPoints > mvpPoints) {
        mvp = player;
      }
    }
    return mvp;
  }

  void _showAddPlayerDialog(LocalTeam team, bool isTeam1) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1a2e),
        title: Text('Add Player', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Player name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final playerId =
                    '${team.id}_player_${team.players.length + 1}';
                team.players.add(Player(
                  id: playerId,
                  name: nameController.text,
                ));
                widget.onMatchUpdate(widget.match);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _changePlayerPhoto(Player player) async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        player.photoPath = image.path;
      });
    }
  }
}
