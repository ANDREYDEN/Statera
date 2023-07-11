import 'package:flutter/material.dart';

class ColorState extends ChangeNotifier {
  Color color;

  ColorState({Color? color}) : color = color ?? Color(0xFFffd100);

  void setColor(Color color) {
    this.color = color;
    notifyListeners();
  }
}
