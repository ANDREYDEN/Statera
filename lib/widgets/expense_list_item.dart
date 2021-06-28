import 'package:flutter/material.dart';
import 'package:statera/models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
      },
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(this.expense.name),
            Text("\$${this.expense.total.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
