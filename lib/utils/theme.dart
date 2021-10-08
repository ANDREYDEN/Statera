import 'package:flutter/material.dart';
import 'package:statera/utils/helpers.dart';

final theme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: createMaterialColor(Colors.black),
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
  ),
  textButtonTheme: textButtonTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(cardBorderRadius),)
    ),
  ),
  fontFamily: "Nunito",
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: createMaterialColor(Colors.white),
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Color(0xFFffd100),
    onSecondary: Colors.black,
  ),
  textButtonTheme: textButtonTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedLabelStyle: TextStyle(color: Colors.white),
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

const cardBorderRadius = 20.0;
