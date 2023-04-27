import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/warning_icon.dart';

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
            child: WarningIcon(),
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
