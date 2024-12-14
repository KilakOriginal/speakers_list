import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'settings_screen.dart';
import '../util/undo_action.dart';
import '../util/l10n.dart';
import '../models/section.dart';

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

  List<Section> _sections = [Section(name: '${L10n.translate('section')} 1')];
  TextEditingController _controller = TextEditingController();
  int _selectedIndex = -1;
  bool _timerActive = false;
  int _maxTimePerSpeaker = 600; // 10 minutes in seconds
  int _currentTime = 600; // 10 minutes in seconds
  Timer? _timer;

  void _addSection() {
    setState(() {
      _sections.add(Section(name: '${L10n.translate('section')} ${_sections.length + 1}'));
    });
  }

  void _renameSection(Section section) {
    _editController.text = section.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(L10n.translate('edit_section')),
          content: TextField(
            controller: _editController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(L10n.translate('cancel')),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(L10n.translate('save')),
              onPressed: () {
                if (_editController.text.isNotEmpty) {
                  setState(() {
                    _undoStack.add(UndoAction(type: 'rename_section', speakers: List.from(section.speakers), index: _sections.indexOf(section)));
                    section.name = _editController.text;
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

  void _closeSection(Section section) {
    setState(() {
      section.isOpen = false;
      if (section.speakers.isEmpty) {
        _undoStack.add(UndoAction(type: 'remove_section', speakers: List.from(section.speakers), index: _sections.indexOf(section)));
        _sections.remove(section);
      }
    });
  }

  void _toggleSectionLock(Section section) {
    setState(() {
      section.isOpen = !section.isOpen;
    });
  }

  void _addSpeakerToSection(Section section, String name) {
    setState(() {
      _undoStack.add(UndoAction(type: 'add_speaker', speakers: List.from(section.speakers), index: _sections.indexOf(section)));
      section.speakers.add(name);
    });
  }

  void _removeSpeaker(Section section, String speaker) {
    setState(() {
      _undoStack.add(UndoAction(type: 'remove_speaker', speakers: List.from(section.speakers), name: speaker, index: _sections.indexOf(section)));
      section.speakers.remove(speaker);
      if (section.speakers.isEmpty) {
        _sections.remove(section);
      }
    });
  }

  void _editName(int index) {
    Section topmostOpenSection = _sections.firstWhere((section) => section.isOpen);
    _editController.text = topmostOpenSection.speakers[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(L10n.translate('edit_name')),
          content: TextField(
            controller: _editController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(L10n.translate('cancel')),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(L10n.translate('save')),
              onPressed: () {
                if (_editController.text.isNotEmpty) {
                  setState(() {
                    _undoStack.add(UndoAction(type: 'rename_speaker', speakers: List.from(topmostOpenSection.speakers), index: index, name: topmostOpenSection.speakers[index]));
                    topmostOpenSection.speakers[index] = _editController.text;
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
      if (_sections[0].speakers.isNotEmpty) {
        _undoStack.add(UndoAction(type: 'next_speaker', speakers: List.from(_sections[0].speakers), name: _sections[0].speakers[0], timeRemaining: _currentTime, index: 0));
        _sections[0].speakers.removeAt(0);
        if (_sections[0].speakers.isNotEmpty) {
          _currentTime = _maxTimePerSpeaker;
        } else {
          _timer?.cancel();
          _timerActive = false;
          _sections.removeAt(0); // Remove the section if it becomes empty
        }
      }
    });
  } 

  void undo() {
    if (_undoStack.isNotEmpty) {
      final action = _undoStack.removeLast();
      setState(() {
        switch (action.type) {
          case 'add_speaker':
            _sections[action.index].speakers = action.speakers!;
            break;
          case 'remove_speaker':
            _sections[action.index].speakers = action.speakers!;
            break;
          case 'rename_speaker':
            _sections[action.index].speakers = action.speakers!;
            break;
          case 'next_speaker':
            _sections[0].speakers = action.speakers!;
            _currentTime = action.timeRemaining!;
            break;
          case 'rename_section':
            _sections[action.index].speakers = action.speakers!;
            break;
          case 'remove_section':
            _sections.insert(action.index, Section(name: action.name!, speakers: action.speakers!));
            break;
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_timerActive && _sections[0].speakers.isNotEmpty) {
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
    if (_sections[0].speakers.isNotEmpty) {
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
      if (_sections[0].speakers.isNotEmpty) {
        _currentTime = newTimeLimit;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _timerActive = false;
    _sections.first.isOpen = true; // Expand the topmost section immediately
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
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addSpeakerToSection(_sections.first, value);
                          _controller.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: L10n.translate('name_prompt'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_sections.isNotEmpty && _sections[0].speakers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '${L10n.translate('current_speaker')}:',
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
                                _sections[0].speakers[0],
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
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final section = _sections.removeAt(oldIndex);
                          _sections.insert(newIndex, section);
                        });
                      },
                      children: _sections.map((section) {
                        return ExpansionTile(
                          key: ValueKey(section.name),
                          initiallyExpanded: section == _sections.first,
                          title: Row(
                            children: [
                              Text(section.name),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.person_add),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(L10n.translate('add_speaker')),
                                        content: TextField(
                                          controller: _controller,
                                          decoration: InputDecoration(
                                            hintText: L10n.translate('name_prompt'),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(L10n.translate('cancel')),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text(L10n.translate('add')),
                                            onPressed: () {
                                              if (_controller.text.isNotEmpty) {
                                                _addSpeakerToSection(section, _controller.text);
                                                _controller.clear();
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          leading: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _renameSection(section),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: !section.isOpen,
                                  onChanged: (value) => _toggleSectionLock(section),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 16.0),
                                child: Icon(section.isOpen ? Icons.lock_open : Icons.lock),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              height: 200, // Set a fixed height for the ReorderableListView
                              child: ReorderableListView(
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex--;
                                    final speaker = section.speakers.removeAt(oldIndex);
                                    section.speakers.insert(newIndex, speaker);
                                  });
                                },
                                children: section.speakers.skip(section == _sections.first ? 1 : 0).map((speaker) { // Skip the first speaker for the first section
                                  int index = section.speakers.indexOf(speaker);
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
                                        _removeSpeaker(section, speaker);
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
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 8), // Small margin before the plus button
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.add_circle),
                    onPressed: _addSection,
                  ),
                  SizedBox(height: 8), // Small margin after the plus button
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
                      child: Text(_timerActive ? L10n.translate('pause_timer') : L10n.translate('start_timer')),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _nextSpeaker,
                      child: Text(L10n.translate('next_speaker')),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 32),
                    SizedBox(width: 8),
                    Text(
                      _formatTime(_currentTime),
                      style: TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
