import 'package:flutter/material.dart';

final textButtonTheme = TextButtonThemeData(
  style: ButtonStyle(
    textStyle: MaterialStateProperty.all(
      TextStyle(
        decoration: TextDecoration.underline,
      ),
    ),
  ),
);

final cardTheme = CardTheme(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);
