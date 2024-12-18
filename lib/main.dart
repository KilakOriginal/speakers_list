import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'util/l10n.dart';
import 'util/language_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();
  Future<void>? _initialization;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await L10n.load(_language); // Load default language
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _setLanguage(String language) async {
    await L10n.load(language);
    setState(() {
      _language = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return LanguageProvider(
            language: _language,
            setLanguage: _setLanguage,
            child: Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): const UndoIntent(),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  UndoIntent: CallbackAction<UndoIntent>(
                    onInvoke: (UndoIntent intent) => _homeScreenKey.currentState?.undo(),
                  ),
                },
                child: MaterialApp(
                  title: 'Speaker Timer',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    brightness: Brightness.light,
                    textTheme: TextTheme(
                      bodyLarge: TextStyle(color: Colors.black),
                      bodyMedium: TextStyle(color: Colors.black),
                    ),
                  ),
                  darkTheme: ThemeData(
                    primarySwatch: Colors.blue,
                    brightness: Brightness.dark,
                    textTheme: TextTheme(
                      bodyLarge: TextStyle(color: Colors.white),
                      bodyMedium: TextStyle(color: Colors.white),
                    ),
                  ),
                  themeMode: _themeMode,
                  home: HomeScreen(key: _homeScreenKey, setThemeMode: _setThemeMode),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class UndoIntent extends Intent {
  const UndoIntent();
}