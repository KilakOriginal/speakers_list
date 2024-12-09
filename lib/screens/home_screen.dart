import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/name_provider.dart';
import 'package:flutter_app/widgets/name_list.dart';
import 'package:flutter_app/widgets/timer_widget.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NameProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Name List'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: NameList()),
            TimerWidget(),
          ],
        ),
      ),
    );
  }
}