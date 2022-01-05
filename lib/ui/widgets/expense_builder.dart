import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class ExpenseBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Expense) builder;

  const ExpenseBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (expenseContext, state) {
        if (state is ExpenseLoaded && state.updateFailure != null) {
          showSnackBar(
            expenseContext,
            state.updateFailure == ExpenseUpdateFailure.ExpenseFinalized
                ? 'Expense is finalized and can no longer be edited'
                : "You don't have access to edit this expense",
          );
        }

        if (state is ExpenseError) {
          showSnackBar(
            context,
            state.error.toString(),
            duration: Duration.zero,
          );
        }
      },
      listenWhen: (before, after) =>
          (before is ExpenseLoaded && after is ExpenseLoaded) ||
          after is ExpenseError,
      builder: (expenseContext, state) {
        if (state is ExpenseLoading) {
          return Center(child: Loader());
        }

        if (state is ExpenseLoaded) {
          return builder(expenseContext, state.expense);
        }

        return Container();
      },
    );
  }
}
