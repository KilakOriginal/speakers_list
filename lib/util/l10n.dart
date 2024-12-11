import 'dart:convert';
import 'package:flutter/services.dart';

class L10n {
  static Map<String, String> _localizedStrings = {};

  static Future<void> load(String locale) async {
    String jsonString = await rootBundle.loadString('assets/languages/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}