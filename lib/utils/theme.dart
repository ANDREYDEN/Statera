import 'package:flutter/material.dart';
import 'package:statera/utils/helpers.dart';

final theme = ThemeData(
  primarySwatch: createMaterialColor(Colors.black),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  fontFamily: "Nunito",
);

final darkTheme = ThemeData(
  primarySwatch: createMaterialColor(Colors.white),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  fontFamily: "Nunito",
);
