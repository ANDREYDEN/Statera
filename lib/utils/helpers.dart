import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

String getRandomLetter() {
  int asciiCode = 97 + Random().nextInt(26);
  return String.fromCharCode(asciiCode);
}

String toStringPrice(double value) {
  return "\$${value.toStringAsFixed(2)}";
}

Future<bool> snackbarCatch(BuildContext context, dynamic Function() operation,
    {String? successMessage}) async {
  String errorMessage = "";
  try {
    await operation();
  } catch (e) {
    errorMessage = e.toString();
  }

  if (errorMessage.isNotEmpty ||
      (successMessage != null && successMessage.isNotEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage.isNotEmpty ? errorMessage : successMessage!),
      margin: EdgeInsets.all(8),
      backgroundColor: errorMessage.isNotEmpty
          ? Theme.of(context).errorColor
          : Theme.of(context).accentColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  return errorMessage.isEmpty;
}
