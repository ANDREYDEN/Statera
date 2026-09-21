import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/actions_button.dart';

class ExpenseActionsButton extends StatelessWidget {
  final Expense expense;

  const ExpenseActionsButton({Key? key, required this.expense})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);
    final featureService = context.read<FeatureService>();

    return GroupBuilder(
      builder: (context, group) {
        final actions = [
          ShareExpenseAction(expense),
          if (expense.canBeUpdatedBy(authBloc.uid)) ...[
            SettingsExpenseAction(expense),
            TaxAllItemsAction(expense),
            if (featureService.authorAssigneeDecisionsEnabled &&
                group.allowAuthorsToMarkOnBehalfOfOthers)
              ImpersonateExpenseAction(expense),
            if (isWide) DeleteExpenseAction(expense),
          ],
          if (expense.isAuthoredBy(authBloc.uid) && expense.finalized)
            RevertExpenseAction(expense),
        ];

        return ActionsButton(
          tooltip: 'Expense actions',
          actions: actions,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
        );
      },
    );
  }
}
