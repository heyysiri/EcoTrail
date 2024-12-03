// import 'package:flutter/material.dart';
// import 'DashboardPage.dart'; // Import the dashboard page

// class HomePage extends StatefulWidget {
//   final String currentUsername; // Add username parameter

//   const HomePage({Key? key, required this.currentUsername}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   // Method to handle navigation based on index
//   void _navigateToPage(BuildContext context, int index) {
//     switch (index) {
//       case 1:
//         Navigator.pushNamed(context, '/game'); // Navigate to GamePage
//         break;
//       case 2:
//         Navigator.pushNamed(context, '/sustainability'); // Navigate to SustainabilityPage
//         break;
//       case 3:
//         Navigator.pushNamed(context, '/settings'); // Navigate to SettingsPage
//         break;
//       default:
//         // Do nothing for index 0, as it is the current page (HomePage)
//         break;
//     }
//   }

//   void _onItemTapped(int index) {
//     if (_selectedIndex != index) {
//       _navigateToPage(context, index); // Navigate to the respective page
//     }
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: DashboardPage(currentUsername: widget.currentUsername),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.videogame_asset),
//             label: 'Game',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.eco),
//             label: 'Sustainability',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.green.shade700,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:frontend/RoutePointsPage.dart';
import 'DashboardPage.dart'; 
import 'RoutePointsPage.dart';
import 'settings_page.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  final String username; 
  HomePage({required this.username}); //
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(currentUsername: widget.username), // Pass username here
      GamePage(),
      RoutePointsPage(username: widget.username),
      SettingsPage(currentUsername:widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _pages[_selectedIndex], // Display the selected page
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
