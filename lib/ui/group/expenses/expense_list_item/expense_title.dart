import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/warning_icon.dart';

class ExpenseTitle extends StatelessWidget {
  final UserExpense userExpense;
  const ExpenseTitle({Key? key, required this.userExpense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (userExpense.hasItemsDeniedByAll) ...[
          Tooltip(
            message:
                'This expense contains items that were not marked by any of the assignees',
            child: WarningIcon(),
          ),
          SizedBox(width: 5),
        ],
        Expanded(
          child: Text(
            this.userExpense.name,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
