import 'package:flutter/material.dart';
import '../models/name.dart';

class NameItem extends StatelessWidget {
  final Name name;
  NameItem(this.name);

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Name'),
              onTap: () {
                Navigator.pop(context);
                _editName(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Remove Speaker'),
              onTap: () {
                Navigator.pop(context);
                _removeSpeaker(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _editName(BuildContext context) {
    // Implement the logic to edit the name
  }

  void _removeSpeaker(BuildContext context) {
    // Implement the logic to remove the speaker
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name.name),
      onTap: () {
        // Handle tap
      },
      onLongPress: () {
        _showContextMenu(context);
      },
    );
  }
}