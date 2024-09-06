import 'package:flutter/material.dart';

const themeSecondary = Color.fromARGB(255, 93, 89, 131);
const themeSecondaryLight = Color.fromARGB(255, 222, 231, 255);

const themePrimary = Color.fromARGB(255, 32, 48, 79);
const themePrimaryAccent = Color.fromARGB(255, 0, 38, 114);
const themePrimaryLight = Color.fromARGB(255, 171, 182, 211);

const themeAccent = Color.fromARGB(255, 253, 185, 93);

const themeLight = Color.fromARGB(255, 248, 250, 255);
const themeDark = Color.fromARGB(255, 46, 44, 57);
const cardColor = themeLight;

const themePadding = 10.0;
const themePaddingEdgeInset = EdgeInsets.all(themePadding);
const double strokeWidth = 2;

double sideMargin(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return (size.width - 1200).clamp(themePadding * 2, double.infinity) / 2;
}

// Based on material 3
const double themeRadius = 25;
const themeCircularRadius = Radius.circular(themeRadius);
const themeBorderRadius = BorderRadius.all(themeCircularRadius);

const blobHeight = 50.0;
const blobWidth = 200.0;
const MENU_WIDTH = 250.0;

final ThemeData currentTheme = AppTheme.lightTheme;

class AppTheme with ChangeNotifier {
  static bool _isDarkTheme = false;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeSecondary,
        brightness: Brightness.light,
        onPrimary: themeLight,
        primary: themePrimary,
        secondary: themeSecondary,
      ),
      scaffoldBackgroundColor: themeLight,
      cardColor: cardColor,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          color: themeAccent,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          color: themeLight,
          fontWeight: FontWeight.normal,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          color: themeLight,
          fontWeight: FontWeight.normal,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: themeDark,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: themeDark,
          fontWeight: FontWeight.normal,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          color: themeDark,
          fontWeight: FontWeight.bold,
        ),
        // You can define more text styles here
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeAccent,
          foregroundColor: themePrimary,
          minimumSize: const Size.fromHeight(
              50), // This makes the button take full width
          shape: const RoundedRectangleBorder(borderRadius: themeBorderRadius),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData();
  }
}

final themeData = AppTheme.lightTheme;
