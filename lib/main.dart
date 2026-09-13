import 'package:ai_glass/screens/welcome_screen.dart';
//import 'package:ai_glass/screens/home_screen.dart';  // Import your HomeScreen
//import 'package:ai_glass/screens/settings_screen.dart'; // Import your SettingsScreen
//import 'package:ai_glass/screens/help_screen.dart'; // Import your HelpScreen
import 'package:ai_glass/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_glass/screens/GPSPage.dart';

import 'screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      // Conditional home based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User logged in => go to HomeScreen
            return const HomeScreen();
          } else {
            // Not logged in => show WelcomeScreen (sign-in/sign-up)
            return const WelcomeScreen();
          }
        },
      ),

      // Define named routes for navigation
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
      //  '/settings': (context) => const SettingsScreen(),
      //  '/help': (context) => const HelpScreen(),
        '/gps': (context) =>  GPSPage(),
        // Add more routes here as needed
      },
    );
  }
}
