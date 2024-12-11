import 'package:flutter/material.dart';
import '../util/l10n.dart';
import '../util/language_provider.dart';

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
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedTimeLimit = widget.initialTimeLimit ~/ 60; // Convert seconds to minutes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = LanguageProvider.of(context)?.language ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.translate('settings')),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              title: Text(L10n.translate('dark_mode')),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  widget.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            ListTile(
              title: Text(L10n.translate('time_limit')),
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
            ListTile(
              title: Text(L10n.translate('language')),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: ['en', 'de'].map((String value) { // Add more languages as needed
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()), // Display language code in uppercase
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                    LanguageProvider.of(context)?.setLanguage(value);
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