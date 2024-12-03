import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final String currentUsername; 
  DashboardPage({required this.currentUsername});
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Points section remains unchanged
  int _pointsEarned = 0;
  List<LeaderboardEntry> _leaderboard = [];
  
  // Trip statistics
  int _walkingTrips = 0;
  int _drivingTrips = 0;
  int _transitTrips = 0;
  int _bicyclingTrips = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
    _fetchLeaderboardData();
  }

   Future<void> _fetchUserPoints() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.12.171:5000/get_user_points?username=${widget.currentUsername}')
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _pointsEarned = userData['sustainability_points'];
          
          // Trip statistics
          _walkingTrips = userData['walking_trips'] ?? 0;
          _drivingTrips = userData['driving_trips'] ?? 0;
          _transitTrips = userData['transit_trips'] ?? 0;
          _bicyclingTrips = userData['bicycling_trips'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user points: $e');
    }
  }

    Future<void> _fetchLeaderboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.12.171:5000/get_leaderboard')
      );

      print('Leaderboard Response Status Code: ${response.statusCode}');
      print('Leaderboard Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Validate the response structure
        if (responseData['leaderboard'] == null) {
          throw Exception('Leaderboard data is null');
        }

        final List<dynamic> leaderboardData = responseData['leaderboard'];
        
        // Convert to LeaderboardEntry with null and type checking
        List<LeaderboardEntry> processedLeaderboard = leaderboardData
          .where((entry) => 
            entry != null && 
            entry['username'] != null && 
            entry['sustainability_points'] != null
          )
          .map((entry) => LeaderboardEntry(
            entry['username'] == widget.currentUsername ? 'You' : entry['username'], 
            // Ensure points is converted to int, default to 0 if null
            int.tryParse(entry['sustainability_points'].toString()) ?? 0
          )).toList()
          ..sort((a, b) => b.points.compareTo(a.points));

        setState(() {
          _leaderboard = processedLeaderboard;
        });

        // Debug print
        print('Processed Leaderboard: ${_leaderboard.map((e) => '${e.name}: ${e.points}')}');
      } else {
        // Handle non-200 status code
        print('Failed to fetch leaderboard. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch leaderboard: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leaderboard: $e')),
      );
      setState(() {
        _leaderboard = [
          LeaderboardEntry("Error", 0)
        ];
      });
    }
  }
  // Progress tracking mock data
 Widget _buildProgressSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            _buildTripStatItem(
              icon: Icons.directions_walk,
              label: 'Walking Trips',
              count: _walkingTrips
            ),
            _buildTripStatItem(
              icon: Icons.directions_bus,
              label: 'Transit Trips',
              count: _transitTrips
            ),
            _buildTripStatItem(
              icon: Icons.directions_bike,
              label: 'Bicycling Trips',
              count: _bicyclingTrips
            ),
            _buildTripStatItem(
              icon: Icons.directions_car,
              label: 'Driving Trips',
              count: _drivingTrips
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build individual trip stat items
  Widget _buildTripStatItem({
    required IconData icon, 
    required String label, 
    required int count
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade600),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label, 
              style: TextStyle(fontSize: 16)
            )
          ),
          Text(
            '$count', 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }


  // Daily motivation quote
  final String _dailyQuote = "Every small action counts towards a sustainable future.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Points Earned Section
          _buildPointsSection(),
          
          SizedBox(height: 20),
          
          // Leaderboard Section
          _buildLeaderboardSection(),
          
          SizedBox(height: 20),
          
          // Track Progress Section
          _buildProgressSection(),
          
          SizedBox(height: 20),
          
          // Quote of the Day Section
          _buildQuoteSection(),
        ],
      ),
    );
  }

  Widget _buildPointsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Points Earned',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '$_pointsEarned',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: _leaderboard.map((entry) => 
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.name, 
                        style: TextStyle(
                          fontWeight: entry.name == "You" ? FontWeight.bold : FontWeight.normal,
                          color: entry.name == "You" ? Colors.green.shade700 : Colors.black,
                        )
                      ),
                      Text(
                        '${entry.points}',
                        style: TextStyle(
                          fontWeight: entry.name == "You" ? FontWeight.bold : FontWeight.normal,
                          color: entry.name == "You" ? Colors.green.shade700 : Colors.black,
                        )
                      ),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildQuoteSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Quote of the Day',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '"$_dailyQuote"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper classes for data management
class LeaderboardEntry {
  final String name;
  final int points;

  LeaderboardEntry(this.name, this.points);
}

// class ProgressItem {
//   final String title;
//   final double progress;
//   final IconData icon;

//   ProgressItem(this.title, this.progress, this.icon);
// }