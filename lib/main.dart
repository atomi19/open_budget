import 'package:flutter/material.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/currency_manager.dart';
import 'package:open_budget/pages/home_page.dart';
import 'package:open_budget/themes/dark_theme.dart';
import 'package:open_budget/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = await AppSettings.getTheme() ?? ThemeMode.system;
  await CurrencyManager.loadCurrency();
  runApp(MainApp(initialTheme: theme));
}

class MainApp extends StatefulWidget {
  final ThemeMode initialTheme;
  const MainApp({
    super.key,
    required this.initialTheme,
  });

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
  }
  
  // set app theme 
  void setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      switch (mode) {
        case ThemeMode.light:
          AppSettings.setTheme('light');
          break;
        case ThemeMode.system:
          AppSettings.setTheme('system');
          break;
        case ThemeMode.dark:
          AppSettings.setTheme('dark');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: HomePage(setTheme: setTheme)
    );
  }
}
