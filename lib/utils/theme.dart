import 'package:flutter/material.dart';
import 'package:statera/utils/helpers.dart';

final theme = ThemeData(
  textButtonTheme: textButtonTheme,
  primarySwatch: createMaterialColor(Colors.black),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  fontFamily: "Nunito",
);

final darkTheme = ThemeData(
  textButtonTheme: textButtonTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedLabelStyle: TextStyle(color: Colors.white),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Color(0xFFffd100),
    onSecondary: Colors.black,
  ),
  fontFamily: "Nunito",
);

final textButtonTheme = TextButtonThemeData(
  style: ButtonStyle(
    textStyle: MaterialStateProperty.all(
      TextStyle(
        decoration: TextDecoration.underline,
      ),
    ),
  ),
);
