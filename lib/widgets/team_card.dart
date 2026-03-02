import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String teamName;
  final VoidCallback? onTap;

  TeamCard({
    required this.teamName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(teamName),
        onTap: onTap,
      ),
    );
  }
}