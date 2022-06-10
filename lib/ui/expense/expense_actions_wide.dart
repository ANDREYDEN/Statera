import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/dynamic_link_service.dart';
import 'package:statera/ui/expense/expense_action_handlers.dart';
import 'package:statera/ui/widgets/buttons/share_button.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class ExpenseActionsWide extends StatelessWidget {
  final Expense expense;

  const ExpenseActionsWide({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensesCubit = context.read<ExpensesCubit>();
    final authBloc = context.read<AuthBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ShareButton(
            data: DynamicLinkService.generateDynamicLink(
              path: ModalRoute.of(context)!.settings.name,
            ),
            webIcon: Icons.share,
          ),
          if (expense.canBeUpdatedBy(authBloc.uid)) ...[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => handleSettingsClick(context),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => OKCancelDialog(
                    text:
                        'Are you sure you want to delete this expense and all of its items?',
                  ),
                );
                if (confirmed == true) expensesCubit.deleteExpense(expense);
              },
            ),
          ]
        ],
      ),
    );
  }
}
