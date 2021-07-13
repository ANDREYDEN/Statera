import 'package:flutter/material.dart';

class ExpenseListEmpty extends StatelessWidget {
  final String text;
  const ExpenseListEmpty({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        this.text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 24,
        ),
      ),
    );
  }
}
