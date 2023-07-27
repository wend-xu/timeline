import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeData themeData;

  ThemeProvider(this.themeData);

  void refreshTheme(ThemeData newTheme){
    themeData = newTheme;
    notifyListeners();
  }
}