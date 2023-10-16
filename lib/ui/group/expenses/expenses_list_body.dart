import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/expenses/expense_list_item/expense_list_item.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

class ExpensesListBody extends StatelessWidget {
  const ExpensesListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final scrollController = ScrollController();
    final isWide = context.select((LayoutState state) => state.isWide);

    const loadingThreshold = 200.0;
    scrollController.addListener(() {
      final distanceToBottom = scrollController.position.maxScrollExtent -
          scrollController.position.pixels;
      if (distanceToBottom < loadingThreshold) {
        context.read<ExpensesCubit>().loadMore(authBloc.uid);
      }
    });

    return ExpensesBuilder(
      builder: (context, expenses, allLoaded) {
        if (expenses.isEmpty) {
          return ListEmpty(text: 'Start by adding an expense');
        }

        return ListView.separated(
          itemCount: expenses.length + 1,
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index == expenses.length && !allLoaded) {
              return Center(child: CircularProgressIndicator());
            }

            var expense = expenses[index];

            return OptionallyDismissible(
              key: Key(expense.id!),
              isDismissible: !isWide && expense.canBeUpdatedBy(authBloc.uid),
              confirmation:
                  'Are you sure you want to delete this expense and all of its items?',
              onDismissed: (_) =>
                  context.read<ExpensesCubit>().deleteExpense(expense),
              child: ExpenseListItem(expense: expense),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 10),
        );
      },
    );
  }
}
