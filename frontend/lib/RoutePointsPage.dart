import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutePointsPage extends StatefulWidget {
  final String username;

  const RoutePointsPage({Key? key, required this.username}) : super(key: key);

  @override
  _RoutePointsPageState createState() => _RoutePointsPageState();
}

class _RoutePointsPageState extends State<RoutePointsPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<String> _selectedModes = ['walking'];
  bool _isLoading = false;
  
  // Result variables
  String _resultMessage = '';
  int _totalPointsEarned = 0;
  List<dynamic> _routeDetails = [];
  dynamic _ecoFriendlyRoute;
  String? _mapImageUrl;

  final List<String> _transportModes = [
    'walking', 
    'bicycling', 
    'transit', 
    'driving'
  ];

  Future<void> _calculateRoutePoints() async {
    if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both origin and destination')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _mapImageUrl = null; // Reset map image
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.12.171:5000/calculate_route_points'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': widget.username,
          'origin': _originController.text,
          'destination': _destinationController.text,
          'modes': _selectedModes,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _resultMessage = responseData['message'];
          _totalPointsEarned = responseData['total_points_earned'];
          _routeDetails = responseData['route_details'];
          _ecoFriendlyRoute = responseData['eco_friendly_route'];
          _mapImageUrl = responseData['map_image']; 
        });

        _showResultDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'An error occurred')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    void _showFullMapView() {
    if (_mapImageUrl == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Full Route Map'),
            backgroundColor: Colors.green,
          ),
          body: Center(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Image.memory(
                base64Decode(_mapImageUrl!.split(',')[1]),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 100);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Route Analysis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Points Earned: $_totalPointsEarned'),
                SizedBox(height: 10),
                
                Text('Route Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._routeDetails.map((route) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mode: ${route['mode']}'),
                    Text('Distance: ${route['distance'].toStringAsFixed(2)} km'),
                    Text('Duration: ${route['duration'].toStringAsFixed(1)} mins'),
                    Text('Points Earned: ${route['points_earned']}'),
                    Text('Carbon Footprint: ${route['carbon_footprint'].toStringAsFixed(2)} kg CO₂'),
                    Divider(),
                  ],
                )).toList(),
                
                if (_ecoFriendlyRoute != null) ...[
                  Text('Eco-Friendly Recommendation:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Recommended Mode: ${_ecoFriendlyRoute['mode']}'),
                ],

                if (_mapImageUrl != null)
                  Center(
                    child: ElevatedButton(
                      onPressed: _showFullMapView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('See Map'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculate Route Points'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Starting Point',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination Point',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              MultiSelectChip(
                _transportModes,
                onSelectionChanged: (selectedList) {
                  setState(() {
                    _selectedModes = selectedList;
                  });
                },
                selectedList: _selectedModes,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _calculateRoutePoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Calculate Route Points', 
                    style: TextStyle(fontSize: 16),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Existing MultiSelectChip and StringExtension code remains the same

// Multi-select chip widget
class MultiSelectChip extends StatefulWidget {
  final List<String> itemList;
  final Function(List<String>) onSelectionChanged;
  final List<String> selectedList;

  const MultiSelectChip(
    this.itemList, {
    required this.onSelectionChanged,
    required this.selectedList,
  });

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.itemList.map((item) {
        return FilterChip(
          label: Text(item.capitalize()),
          selected: widget.selectedList.contains(item),
          onSelected: (bool value) {
            List<String> newSelectedList = List.from(widget.selectedList);
            if (value) {
              newSelectedList.add(item);
            } else {
              newSelectedList.remove(item);
            }
            widget.onSelectionChanged(newSelectedList);
          },
        );
      }).toList(),
    );
  }
}

// Extension to capitalize first letter of words
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}