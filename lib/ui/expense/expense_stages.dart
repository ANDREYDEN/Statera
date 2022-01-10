import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/expense.dart';


class ExpenseStages extends StatelessWidget {
  final Expense expense;

  const ExpenseStages({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authBloc = context.read<AuthBloc>();

    return Row(
      children: [
        for (var expenseStage in authBloc.expenseStages)
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
