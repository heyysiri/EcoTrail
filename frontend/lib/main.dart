import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

import 'package:frontend/login_page.dart';
import 'package:frontend/sign_up_page.dart';
import 'package:frontend/home_page.dart';
import 'package:frontend/settings_page.dart';
import 'package:frontend/game_page.dart';

// Main function to run the app
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(EcoTrailApp());
}

// The main app widget
class EcoTrailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrail',
      initialRoute: '/',  // Define the initial route
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        // '/home': (context) => HomePage(),
        // '/settings':(context) => SettingsPage(),
        '/game':(context) => GamePage(),
      },
    );
  }
}

// WelcomePage Widget
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // List of static eco-friendly tips
  final List<String> ecoTips = [
    "Reduce, Reuse, Recycle!",
    "Turn off lights when not in use.",
    "Use public transport or carpool.",
    "Avoid single-use plastics.",
    "Plant more trees to clean the air."
  ];

  // Function to show the Eco Tip dialog
  void showEcoTip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Eco-Friendly Tip!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            ecoTips[DateTime.now().second % ecoTips.length],  // Rotate tips based on current second
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Got it!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Show eco tip when the page loads
    Future.delayed(Duration.zero, () {
      showEcoTip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.eco, size: 100, color: Colors.green.shade800),
                Text(
                  "Welcome to EcoTrail",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Plan your eco-friendly commute with ease!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');  // Navigate to LoginPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Login", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');  // Navigate to SignupPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Sign Up", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}