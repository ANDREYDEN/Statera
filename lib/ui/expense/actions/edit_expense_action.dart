part of 'expense_action.dart';

class EditExpenseAction extends EntityAction {
  final Expense expense;

  EditExpenseAction(this.expense);

  @override
  IconData get icon => Icons.edit;

  @override
  String get name => 'Edit';

  @override
  @protected
  FutureOr<void> handle(BuildContext context) async {
    final expensesCubit = context.read<ExpensesCubit>();

    await showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'Edit Expense',
        fields: [
          FieldData(
            id: 'expense_name',
            label: 'Expense name',
            validators: [FieldData.requiredValidator],
            initialData: expense.name,
          ),
        ],
        onSubmit: (values) {
          final updatedExpense = Expense.from(expense);
          updatedExpense.name = values['expense_name']!;
          expensesCubit.updateExpense(updatedExpense, persist: true);
          return updatedExpense;
        },
      ),
    );
  }
}
