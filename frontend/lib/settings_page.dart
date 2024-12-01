import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; // Assuming you have a HomePage defined

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings variables
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  double _carbonGoal = 50.0;

  // Password change controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    // First, validate inputs
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Prepare the request body
    final Map<String, String> passwordData = {
      'old_password': _currentPasswordController.text,
      'new_password': _newPasswordController.text,
    };

    try {
      // Send password change request
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/updatepassword'), // Replace with your actual backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(passwordData),
      );

      // Handle the response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Close the dialog
        Navigator.of(context).pop();
      } else {
        // Parse the error message from the response
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorResponse['error'] ?? 'Password change failed')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green.shade800, // Changed to green
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Account Settings Section
          _buildSectionHeader('Account'),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Change Password'),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),
          ),

          // Preferences Section
          SizedBox(height: 20),
          _buildSectionHeader('Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Notifications'),
                  subtitle: Text('Receive route and eco-impact updates'),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Carbon Reduction Goal'),
                  subtitle: Text('${_carbonGoal.toStringAsFixed(1)} kg CO₂ per month'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showCarbonGoalDialog();
                  },
                ),
              ],
            ),
          ),

          // Appearance Section
          SizedBox(height: 20),
          _buildSectionHeader('Appearance'),
          Card(
            child: SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Switch between light and dark themes'),
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                  // TODO: Implement theme switching logic
                });
              },
            ),
          ),

          // Privacy & Security Section
          SizedBox(height: 20),
          _buildSectionHeader('Privacy & Security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout from All Devices'),
                  onTap: () {
                    // TODO: Implement logout from all devices
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged out from all devices')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Eco-Impact Section
          SizedBox(height: 20),
          _buildSectionHeader('Eco-Impact'),
          Card(
            child: ListTile(
              leading: Icon(Icons.grass),
              title: Text('View Your Environmental Impact'),
              subtitle: Text('Track your carbon reduction journey'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to HomePage
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green, // Changed to green
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Change Password'),
              onPressed: _changePassword,
            ),
          ],
        );
      },
    );
  }

  void _showCarbonGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Carbon Reduction Goal'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Monthly CO₂ Reduction Goal'),
                  Slider(
                    value: _carbonGoal,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${_carbonGoal.toStringAsFixed(1)} kg',
                    onChanged: (double value) {
                      setState(() {
                        _carbonGoal = value;
                      });
                    },
                  ),
                  Text('${_carbonGoal.toStringAsFixed(1)} kg CO₂ per month'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  // Save the carbon goal
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}