part of 'expense_action.dart';

class EditExpenseAction extends EntityAction {
  final UserExpense userExpense;

  EditExpenseAction(this.userExpense);

  @override
  IconData get icon => Icons.edit;

  @override
  String get name => 'Edit';

  @override
  FutureOr<void> handle(BuildContext context) async {
    final expenseService = context.read<ExpenseService>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'Edit Expense',
        fields: [
          FieldData(
            id: 'expense_name',
            label: 'Expense name',
            validators: [FieldData.requiredValidator],
            initialData: userExpense.name,
          )
        ],
        onSubmit: (values) async {
          expenseService.updateExpenseById(userExpense.id, (expense) {
            expense.name = values['expense_name']!;
          });
        },
      ),
    );
  }
}
