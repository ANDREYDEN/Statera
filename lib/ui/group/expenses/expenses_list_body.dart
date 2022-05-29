import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/expenses/expense_list_item.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

class ExpensesListBody extends StatelessWidget {
  final List<Expense> expenses;

  const ExpensesListBody({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = context.read<AuthBloc>();
    ExpensesCubit expensesCubit = context.read<ExpensesCubit>();
    
    return expenses.isEmpty
        ? ListEmpty(text: "Start by adding an expense")
        : ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              var expense = expenses[index];

              return OptionallyDismissible(
                key: Key(expense.id!),
                isDismissible: expense.canBeUpdatedBy(authBloc.uid),
                confirmation:
                    "Are you sure you want to delete this expense and all of its items?",
                onDismissed: (_) => expensesCubit.deleteExpense(expense),
                child: GestureDetector(
                  onLongPress: () => _handleEditExpense(context, expense),
                  child: ExpenseListItem(expense: expense),
                ),
              );
            },
          );
  }

  _handleEditExpense(BuildContext context, Expense expense) {
    ExpensesCubit expensesCubit = context.read<ExpensesCubit>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense name",
            validators: [FieldData.requiredValidator],
            initialData: expense.name,
          )
        ],
        onSubmit: (values) async {
          expense.name = values["expense_name"]!;
          expensesCubit.updateExpense(expense);
        },
      ),
    );
  }
}
