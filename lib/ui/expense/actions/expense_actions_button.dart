import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';

class ExpenseActionsButton extends StatelessWidget {
  final Expense expense;

  const ExpenseActionsButton({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    final actions = [
      ShareExpenseAction(expense),
      if (expense.canBeUpdatedBy(authBloc.uid)) ...[
        SettingsExpenseAction(expense),
        if (isWide) DeleteExpenseAction(expense),
      ],
      if (expense.isAuthoredBy(authBloc.uid) && expense.finalized)
        RevertExpenseAction(expense)
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      child: PopupMenuButton<ExpenseAction>(
        tooltip: 'Expense actions',
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(Icons.more_vert),
        ),
        itemBuilder: (context) => actions.map((action) {
          return PopupMenuItem(
            value: action,
            child: Row(
              children: [
                Icon(
                  action.icon,
                  color: action.getIconColor(context),
                ),
                SizedBox(width: 4),
                Text(action.name),
              ],
            ),
          );
        }).toList(),
        onSelected: (action) => action.safeHandle(context),
      ),
    );
  }
}
