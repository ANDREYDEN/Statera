import 'package:flutter/material.dart';

class ExpenseListEmpty extends StatelessWidget {
  const ExpenseListEmpty({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("No expenses yet...");
  }
}