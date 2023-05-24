import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/expenses/expense_list_item/expense_list_item.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

class ExpensesListBody extends StatelessWidget {
  const ExpensesListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building ExpensesListBody');
    final authBloc = context.read<AuthBloc>();
    final scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<ExpensesCubit>().loadMore(authBloc.uid);
      }
    });

    return ExpensesBuilder(
      builder: (context, expenses) {
        print('Got expenses: ${expenses.length}');
        if (expenses.isEmpty) {
          return ListEmpty(text: 'Start by adding an expense');
        }

        return ListView.builder(
          itemCount: expenses.length + 1,
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index == expenses.length) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            var expense = expenses[index];

            return OptionallyDismissible(
              key: Key(expense.id!),
              isDismissible: expense.canBeUpdatedBy(authBloc.uid),
              confirmation:
                  'Are you sure you want to delete this expense and all of its items?',
              onDismissed: (_) =>
                  context.read<ExpensesCubit>().deleteExpense(expense),
              child: GestureDetector(
                onLongPress: () => _handleEditExpense(context, expense),
                child: ExpenseListItem(expense: expense),
              ),
            );
          },
        );
      },
    );
  }

  _handleEditExpense(BuildContext context, Expense expense) {
    ExpensesCubit expensesCubit = context.read<ExpensesCubit>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'Edit Expense',
        fields: [
          FieldData(
            id: 'expense_name',
            label: 'Expense name',
            validators: [FieldData.requiredValidator],
            initialData: expense.name,
          )
        ],
        onSubmit: (values) async {
          expense.name = values['expense_name']!;
          expensesCubit.updateExpense(expense);
        },
      ),
    );
  }
}
