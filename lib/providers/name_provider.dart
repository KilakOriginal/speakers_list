import 'package:flutter/material.dart';
import '../models/name.dart';

class NameProvider with ChangeNotifier {
  List<Name> _names = [];

  List<Name> get names => _names;

  void addName(Name name) {
    _names.add(name);
    notifyListeners();
  }

  void removeName(Name name) {
    _names.remove(name);
    notifyListeners();
  }
}