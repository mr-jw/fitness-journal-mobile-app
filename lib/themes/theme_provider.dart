import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkTheme => themeMode == ThemeMode.dark;

  void toggleTheme(bool darkModeOn) {
    themeMode = darkModeOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Colors.amber.shade400,
    ),
    focusColor: Colors.green.shade300,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.1,
      backgroundColor: Colors.black,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0.1,
      backgroundColor: Colors.amber.shade400,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: Colors.amber.shade400,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade100,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.green.shade300,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.1,
      backgroundColor: Colors.green.shade300,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0.1,
      backgroundColor: Colors.green.shade300,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.green.shade300,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.green.shade300,
      selectedItemColor: Colors.white,
    ),
  );
}
