import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Method to handle navigation based on index
  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/game'); // Navigate to GamePage
        break;
      case 2:
        Navigator.pushNamed(context, '/sustainability'); // Navigate to SustainabilityPage
        break;
      case 3:
        Navigator.pushNamed(context, '/settings'); // Navigate to SettingsPage
        break;
      default:
        // Do nothing for index 0, as it is the current page (HomePage)
        break;
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _navigateToPage(context, index); // Navigate to the respective page
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.green.shade800,
      ),
      body: Center(
        child: Text(
          "Welcome to the Dashboard",
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
