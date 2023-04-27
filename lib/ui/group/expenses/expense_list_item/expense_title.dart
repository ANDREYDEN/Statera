import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';

class ExpenseTitle extends StatelessWidget {
  final Expense expense;
  const ExpenseTitle({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (expense.hasItemsDeniedByAll) ...[
          Tooltip(
            message:
                'This expense contains items that were not marked by any of the assignees',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
        ],
        Text(
          this.expense.name,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
