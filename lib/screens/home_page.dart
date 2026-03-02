import 'package:flutter/material.dart';
import 'local_dashboard_page.dart';
import 'auth_page.dart';
import 'scan_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/versus.jpeg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.7)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VERSUS',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                _buildButton(
                  context,
                  '🎮 Utiliser en local',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LocalDashboardPage()),
                  ),
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  '🌍 Se connecter / Créer un compte',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AuthPage()),
                  ),
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  '📡 Rejoindre avec QR Code',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScanPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}