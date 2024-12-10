import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  SettingsScreen({required this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setThemeMode(ThemeMode.light);
              },
              child: Text('Switch to Light Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                setThemeMode(ThemeMode.dark);
              },
              child: Text('Switch to Dark Mode'),
            ),
          ],
        ),
      ),
    );
  }
}