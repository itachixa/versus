import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'online_dashboard_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? 'Connexion' : 'Inscription',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 40),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
                  ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Pas de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnlineDashboardPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}