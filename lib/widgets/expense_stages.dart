import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/models/expense.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class ExpenseStages extends StatelessWidget {
  final Expense expense;

  const ExpenseStages({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context, listen: false);
    return Row(
      children: [
        for (var expenseStage in authVm.expenseStages)
          Expanded(
            child: Opacity(
              opacity: expense.isIn(expenseStage) ? 1 : 0.7,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: expenseStage.color, width: 2),
                  color: expense.isIn(expenseStage) ? expenseStage.color : null,
                ),
                child: Center(
                  child: Text(
                    expenseStage.name,
                    style: TextStyle(
                        color: expense.isIn(expenseStage)
                            ? Colors.black
                            : Theme.of(context).textTheme.bodyText1!.color),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
