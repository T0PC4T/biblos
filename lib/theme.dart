import 'package:flutter/material.dart';

const themePrimary = Color.fromARGB(255, 191, 160, 224);
const themePrimaryLight = Color.fromARGB(255, 100, 151, 255);
const themePrimaryLightLight = Color.fromARGB(255, 216, 227, 255);
const themeOnPrimary = Colors.white;
const themeSecondary = Color.fromARGB(255, 80, 121, 255);
const themeBackground = Colors.white;
const themeDark = Color.fromARGB(255, 56, 37, 59);
const themeDarkLight = Color.fromARGB(255, 204, 204, 212);
const themeLight = Color.fromARGB(255, 231, 231, 231);

const themePadding = 18.0;
const themePaddingEdgeInset = EdgeInsets.all(themePadding);
double sideMargin(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return (size.width - 1200).clamp(themePadding * 2, double.infinity) / 2;
}

// Based on material 3
const double themeRadius = 15;
const themeCircularRadius = Radius.circular(30);
const themeBorderRadius = BorderRadius.all(themeCircularRadius);

const textBigHeading = TextStyle(fontSize: 40, color: themeDark);

const textSubheading = TextStyle(fontSize: 35, color: themeDark);

const textSubheadingHighlight = TextStyle(fontSize: 35, color: themePrimary);

const textNormalLight = TextStyle(color: themeLight);
const textLargeText = TextStyle(fontSize: 15, height: 2);
const textThemeMore = TextStyle(fontSize: 20);
const textThemeMoreLight = TextStyle(fontSize: 20, color: themeBackground);

const blobHeight = 60.0;
const blobWidth = 180.0;
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
        seedColor: themePrimary,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData();
  }
}

final themeData = AppTheme.lightTheme;

get disableButtonStyle => ButtonStyle(
      elevation: MaterialStateProperty.all(0),
      minimumSize: MaterialStateProperty.all(const Size(blobWidth, blobHeight)),
      maximumSize:
          MaterialStateProperty.all(const Size(double.infinity, blobHeight)),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return themeDarkLight;
        }
        return themeDark;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return themeOnPrimary;
        }
        return themeOnPrimary;
      }),
      padding: MaterialStateProperty.all(
        const EdgeInsets.all(15),
      ),
      textStyle: const MaterialStatePropertyAll(textThemeMore),
    );
