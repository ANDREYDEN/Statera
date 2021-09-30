import 'package:flutter/material.dart';
import 'package:statera/utils/helpers.dart';

final theme = ThemeData(
  textButtonTheme: textButtonTheme,
  primarySwatch: createMaterialColor(Colors.black),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: 'Nunito',
    ),
    elevation: 0,
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
  ),
  cardTheme: CardTheme(
    color: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  fontFamily: "Nunito",
);

final darkTheme = ThemeData(
  textButtonTheme: textButtonTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'Nunito',
    ),
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
