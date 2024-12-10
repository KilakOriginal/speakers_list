import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'settings_screen.dart';
import '../util/undo_action.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;

  HomeScreen({required Key key, required this.setThemeMode}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _editController = TextEditingController();
  final List<UndoAction> _undoStack = [];
  final int _maxUndoStackSize = 10;
  final FocusNode _focusNode = FocusNode();

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
      if (_speakers.length == 1) {
        _currentTime = _maxTimePerSpeaker;
        _startTimer();
      }
    });
  }

  void _insertSpeaker(String name) {
    setState(() {
      _speakers.insert(1, name);
    });
  }

  void _removeSpeaker(int index) {
    setState(() {
      _undoStack.add(UndoAction(type: 'remove', index: index, name: _speakers[index]));
      if (_undoStack.length > _maxUndoStackSize) {
        _undoStack.removeAt(0);
      }
      _speakers.removeAt(index);
      if (_speakers.isEmpty) {
        _timer?.cancel();
        _timerActive = false;
      }
    });
  }

  void _editName(int index) {
    _editController.text = _speakers[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: _editController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (_editController.text.isNotEmpty) {
                  setState(() {
                    _undoStack.add(UndoAction(type: 'rename', index: index, name: _speakers[index]));
                    if (_undoStack.length > _maxUndoStackSize) {
                      _undoStack.removeAt(0);
                    }
                    _speakers[index] = _editController.text;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _nextSpeaker() {
    setState(() {
      if (_speakers.isNotEmpty) {
        _undoStack.add(UndoAction(type: 'next', index: 0, name: _speakers[0], timeRemaining: _currentTime));
        if (_undoStack.length > _maxUndoStackSize) {
          _undoStack.removeAt(0);
        }
        _speakers.removeAt(0);
        if (_speakers.isNotEmpty) {
          _currentTime = _maxTimePerSpeaker;
        } else {
          _timer?.cancel();
          _timerActive = false;
        }
      }
    });
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      final action = _undoStack.removeLast();
      setState(() {
        switch (action.type) {
          case 'remove':
            _speakers.insert(action.index, action.name!);
            break;
          case 'rename':
            _speakers[action.index] = action.name!;
            break;
          case 'next':
            _speakers.insert(0, action.name!);
            _currentTime = action.timeRemaining!;
            break;
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_timerActive && _speakers.isNotEmpty) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentTime > 0) {
            _currentTime--;
          } else {
            timer.cancel();
            _nextSpeaker();
          }
        });
      });
    }
  }

  void _toggleTimer() {
    if (_speakers.isNotEmpty) {
      setState(() {
        _timerActive = !_timerActive;
        if (_timerActive) {
          _startTimer();
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  void _setTimeLimit(int newTimeLimit) {
    setState(() {
      _maxTimePerSpeaker = newTimeLimit;
      if (_speakers.isNotEmpty) {
        _currentTime = newTimeLimit;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _timerActive = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.undo),
          onPressed: undo,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    setThemeMode: widget.setThemeMode,
                    setTimeLimit: _setTimeLimit,
                    initialTimeLimit: _maxTimePerSpeaker,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0), // Increased right and top padding
                    child: TextField(
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
                  ),
                  SizedBox(height: 16),
                  if (_speakers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Current Speaker:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onDoubleTap: () {
                            _editName(0);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _speakers[0],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  if (_speakers.length > 1)
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Up Next:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (_speakers.length > 1)
                    Flexible(
                      fit: FlexFit.loose,
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          // Adjust indices to account for the current speaker
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          setState(() {
                            final speaker = _speakers.removeAt(oldIndex + 1);
                            _speakers.insert(newIndex + 1, speaker);
                          });
                        },
                        children: _speakers.skip(1).map((speaker) {
                          int index = _speakers.indexOf(speaker);
                          return ListTile(
                            key: ValueKey(speaker),
                            title: GestureDetector(
                              onDoubleTap: () {
                                _editName(index);
                              },
                              child: Text(
                                speaker,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                _removeSpeaker(index);
                              },
                            ),
                            selected: _selectedIndex == index,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
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
                Text('Time Remaining: ${_formatTime(_currentTime)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}