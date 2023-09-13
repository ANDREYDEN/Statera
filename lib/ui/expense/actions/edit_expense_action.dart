part of 'expense_action.dart';

class EditExpenseAction extends ExpenseAction {
  EditExpenseAction(super.expense);

  @override
  IconData get icon => Icons.edit;

  @override
  String get name => 'Edit';

  @override
  FutureOr<void> handle(BuildContext context) async {
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
