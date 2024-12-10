import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  final Function(int) setTimeLimit;
  final int initialTimeLimit;

  SettingsScreen({required this.setThemeMode, required this.setTimeLimit, required this.initialTimeLimit});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedTimeLimit;

  @override
  void initState() {
    super.initState();
    _selectedTimeLimit = widget.initialTimeLimit ~/ 60; // Convert seconds to minutes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  widget.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            ListTile(
              title: Text('Time Limit per Speaker (minutes)'),
              trailing: DropdownButton<int>(
                value: _selectedTimeLimit,
                items: [5, 10, 15, 20, 30, 60].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTimeLimit = value;
                      widget.setTimeLimit(value * 60); // Convert minutes to seconds
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}