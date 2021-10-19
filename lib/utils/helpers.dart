import 'package:intl/intl.dart';
import 'dart:math';

import 'package:flutter/material.dart';

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String toStringPrice(double value) {
  return "\$${value.toStringAsFixed(2)}";
}

String? toStringDate(DateTime? date) {
  return date == null ? null : DateFormat('d MMM, yyyy').format(date);
}

String? toStringDateTime(DateTime? date) {
  return date == null ? null : DateFormat('d MMM, yyyy h:mm:ss a').format(date);
}

Future<bool> snackbarCatch(
  BuildContext context,
  dynamic Function() operation, {
  String? successMessage,
  String? errorMessage,
}) async {
  bool errorOccured = false;
  try {
    await operation();
  } catch (e) {
    errorOccured = true;
    errorMessage = errorMessage ?? e.toString();
  }

  if (errorOccured || (successMessage != null && successMessage.isNotEmpty)) {
    showSnackBar(
      context,
      errorOccured ? errorMessage! : successMessage!,
      color: errorOccured
          ? Theme.of(context).errorColor
          : Theme.of(context).colorScheme.secondary,
    );
  }

  return !errorOccured;
}

void showSnackBar(
  BuildContext context,
  String content, {
  Duration duration = const Duration(seconds: 3),
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      margin: EdgeInsets.all(8),
      backgroundColor: color,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

pluralize(term, quantity) {
  var pluralTerm =
      (quantity % 10 == 1 && quantity % 100 != 11) ? term : '${term}s';
  return '$quantity $pluralTerm';
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
