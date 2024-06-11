import 'package:flutter/material.dart';
import 'package:notes/themedata.dart';
//provider for handling dark and light modes
class ThemeProvider extends ChangeNotifier {
  ThemeData _theme = lightMode;

  ThemeData get theme => _theme;

  void toggle() {
    if (_theme == lightMode) {
      _theme = darkMode;
    } else {
      _theme = lightMode;
    }

    notifyListeners();
  }
}
