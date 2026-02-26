import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.blue, // color for actions 
    onPrimary: Colors.white, // text color
    primaryContainer: Colors.grey.shade800,
    secondary: Colors.white, // text color (e.g. for FilledButton)
    tertiary: Colors.grey.shade500, // icon or subtext color
    surface: const Color(0xFF1E1E1E), // page bg color
  )
);