import 'dart:math';

import 'package:flutter/material.dart';

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String toStringPrice(double value) {
  return "\$${value.toStringAsFixed(2)}";
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
