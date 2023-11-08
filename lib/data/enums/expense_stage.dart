import 'package:flutter/material.dart';

enum ExpenseStage {
  Not_Marked(color: Colors.red, swatchValue: 200),
  Pending(color: Colors.yellow, swatchValue: 300),
  Finalized(color: Colors.grey, swatchValue: 400);

  final MaterialColor _color;
  final int swatchValue;

  const ExpenseStage({
    required MaterialColor color,
    required this.swatchValue,
  }) : _color = color;

  Color get color => _color[swatchValue]!;

  @override
  String toString() {
    return 'ExpenseStage "$name - $index"';
  }
}
