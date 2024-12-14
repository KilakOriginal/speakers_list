import 'package:flutter/widgets.dart';

class Section {
  String name;
  final Key key;
  bool isOpen;
  List<String> speakers;

  Section({required this.name, required this.key, this.isOpen = true, List<String>? speakers})
      : speakers = speakers ?? [];
}