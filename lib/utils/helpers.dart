import 'dart:math';

import 'package:flutter/material.dart';

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String toStringPrice(double value) {
  return "\$${value.toStringAsFixed(2)}";
}

Future<bool> snackbarCatch(BuildContext context, dynamic Function() operation,
    {String? successMessage, String? errorMessage}) async {
  bool errorOccured = false;
  try {
    await operation();
  } catch (e) {
    errorOccured = true;
    errorMessage = errorMessage ?? e.toString();
  }

  if (errorOccured || (successMessage != null && successMessage.isNotEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorOccured ? errorMessage! : successMessage!),
      margin: EdgeInsets.all(8),
      backgroundColor: errorOccured
          ? Theme.of(context).errorColor
          : Theme.of(context).accentColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  return errorOccured;
}
