import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'providers/local_tournament_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BasketApp());
}

class BasketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalTournamentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          colorScheme: ColorScheme.dark(primary: Colors.blueAccent),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}