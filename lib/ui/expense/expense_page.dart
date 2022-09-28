import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/ui/expense/expense_action_handlers.dart';
import 'package:statera/ui/expense/expense_details.dart';
import 'package:statera/ui/expense/expense_share_button.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class ExpensePage extends StatelessWidget {
  static const String route = '/expense';

  const ExpensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, expenseState) {
        if (expenseState is ExpenseLoading) {
          return PageScaffold(
            child: Center(child: Loader()),
          );
        }

        if (expenseState is ExpenseError) {
          return PageScaffold(
            child: Center(child: Text(expenseState.error.toString())),
          );
        }

        if (expenseState is ExpenseLoaded) {
          final expense = expenseState.expense;
          final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);

          return PageScaffold(
            onFabPressed:
                expenseCanBeUpdated ? () => handleItemUpsert(context) : null,
            actions: [
              ExpenseShareButton(),
              if (expense.canBeUpdatedBy(authBloc.uid))
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => handleSettingsClick(context),
                )
            ],
            child: ExpenseDetails(),
          );
        }

        return PageScaffold(child: Container());
      },
    );
  }
}
