import 'package:flutter/material.dart';
import '../models/name.dart';

class NameItem extends StatelessWidget {
  final Name name;
  NameItem(this.name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name.name),
      onTap: () {
        // Handle tap
      },
      onLongPress: () {
        // Handle long press for context menu
      },
    );
  }
}