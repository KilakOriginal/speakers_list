import 'package:flutter/material.dart';

class LanguageProvider extends InheritedWidget {
  final String language;
  final Function(String) setLanguage;

  LanguageProvider({
    required this.language,
    required this.setLanguage,
    required Widget child,
  }) : super(child: child);

  static LanguageProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
  }

  @override
  bool updateShouldNotify(LanguageProvider oldWidget) {
    return oldWidget.language != language;
  }
}