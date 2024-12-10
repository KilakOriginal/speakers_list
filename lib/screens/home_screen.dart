import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;

  HomeScreen({required this.setThemeMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _speakers = [];
  TextEditingController _controller = TextEditingController();
  int _selectedIndex = -1;
  bool _timerActive = false;
  int _maxTimePerSpeaker = 600; // 10 minutes in seconds
  int _currentTime = 600; // 10 minutes in seconds
  Timer? _timer;

  void _addSpeaker(String name) {
    setState(() {
      _speakers.add(name);
    });
  }

  void _insertSpeaker(String name) {
    setState(() {
      _speakers.insert(1, name);
    });
  }

  void _removeSpeaker(int index) {
    setState(() {
      _speakers.removeAt(index);
    });
  }

  void _moveSpeaker(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String speaker = _speakers.removeAt(oldIndex);
      _speakers.insert(newIndex, speaker);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerActive) {
          _currentTime--;
        }
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      _timerActive = !_timerActive;
    });
  }

  void _nextSpeaker() {
    setState(() {
      if (_speakers.isNotEmpty) {
        _speakers.removeAt(0);
        _currentTime = _maxTimePerSpeaker;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speakers List'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(setThemeMode: widget.setThemeMode),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _addSpeaker(value);
                _controller.clear();
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter speaker name',
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _moveSpeaker,
              children: _speakers.map((speaker) {
                int index = _speakers.indexOf(speaker);
                return ListTile(
                  key: ValueKey(speaker),
                  title: Text(
                    speaker,
                    style: TextStyle(
                      fontSize: index == 0 ? 24 : 18,
                      fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                      color: index == 0 ? Colors.black : Colors.grey,
                    ),
                  ),
                  selected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  onLongPress: () {
                    _removeSpeaker(index);
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleTimer,
                child: Text(_timerActive ? 'Pause Timer' : 'Start Timer'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _nextSpeaker,
                child: Text('Next Speaker'),
              ),
            ],
          ),
          Text('Time Remaining: ${_currentTime}s'),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  SettingsScreen({required this.setThemeMode});

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
                  setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            // Add language selection dropdown here
          ],
        ),
      ),
    );
  }
}