import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/expenses/expense_list_item/expense_list_item.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';
import 'package:statera/utils/stream_extensions.dart';

class ExpensesListBody extends StatelessWidget {
  const ExpensesListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    final scrollController = ScrollController();
    final scrollUpdateStreamController = StreamController();
    scrollController.addListener(() {
      scrollUpdateStreamController.add(scrollController.position);
    });
    scrollUpdateStreamController.stream.throttle(1.seconds).listen((_) {
      const loadingThreshold = 20.0;
      final distanceToBottom = scrollController.position.maxScrollExtent -
          scrollController.position.pixels;
      if (distanceToBottom < loadingThreshold) {
        context.read<ExpensesCubit>().loadMore();
      }
    });

    return ExpensesBuilder(
      onStagesChanged: (_, __) {
        scrollController.jumpTo(0);
      },
      builder: (context, expensesState) {
        final expenses = expensesState.expenses;
        if (expenses.isEmpty) {
          return ListEmpty(text: 'Start by adding an expense');
        }

        return ListView.separated(
          itemCount: expenses.length + 1,
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index == expenses.length) {
              if (expensesState.allLoaded) return SizedBox.shrink();
              return Center(child: CircularProgressIndicator());
            }

            var expense = expenses[index];

            return OptionallyDismissible(
              key: Key(expense.id),
              isDismissible: !isWide && expense.canBeUpdatedBy(authBloc.uid),
              confirmation:
                  'Are you sure you want to delete this expense and all of its items?',
              onDismissed: (_) {
                expenses.remove(expense);
                context.read<ExpensesCubit>().deleteExpense(expense.id);
              },
              child: ExpenseListItem(
                expense: expense,
                processing:
                    expensesState.processingExpenseIds.contains(expense.id),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 10),
        );
      },
    );
  }
}
