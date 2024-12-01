import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert';
import 'package:frontend/login_page.dart';
import 'package:frontend/sign_up_page.dart';
import 'package:frontend/home_page.dart';
import 'package:frontend/settings_page.dart';
// Main function to run the app
void main() => runApp(EcoTrailApp());

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
        '/home': (context) => HomePage(),
        '/settings':(context) => SettingsPage(),
      },
    );
  }
}

// WelcomePage Widget
class WelcomePage extends StatelessWidget {
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

