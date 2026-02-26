import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.blue, // color for actions 
    onPrimary: Colors.black, // text color
    primaryContainer: Colors.white,
    secondary: Colors.white, // text color (e.g. for FilledButton)
    tertiary: Colors.grey.shade600, // icon or subtext color
    surface: Colors.grey.shade100, // page bg color
  ),
);