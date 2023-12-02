part of 'expense_action.dart';

class EditExpenseAction extends EntityAction {
  final Expense expense;

  EditExpenseAction(this.expense);

  @override
  IconData get icon => Icons.edit;

  @override
  String get name => 'Edit';

  @override
  FutureOr<void> handle(BuildContext context) async {
    final expenseService = context.read<ExpenseService>();
    final expensesCubit = context.read<ExpensesCubit>();

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
          expensesCubit.process();
          expenseService.updateExpenseById(expense.id, (expense) {
            expense.name = values['expense_name']!;
          });
        },
      ),
    );
  }
}
