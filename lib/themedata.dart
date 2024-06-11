import 'package:flutter/material.dart';

//Light mode colors
ThemeData lightMode = ThemeData(
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFEB7A53),
        onPrimary: Colors.white,
        secondary: Color.fromARGB(255, 255, 224, 123),
        onSecondary: Color.fromARGB(255, 255, 224, 123),
        error: Colors.red,
        onError: Colors.red,
        background: Color(0xFFF6ECC9),
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black));

//dark mode colors
ThemeData darkMode = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFEB7A53), 
    onPrimary: Color(0xFF1C1C1C),
    secondary: Color(0xFF2C2C2C), 
    onSecondary: Color(0xFFCCCCCC),
    error: Colors.red,
    onError: Colors.red,
    background: Color(0xFF1C1C1C), 
    onBackground: Color(0xFFCCCCCC), 
    surface: Color(0xFF2C2C2C),
    onSurface: Color(0xFFCCCCCC), 
  ),
);
