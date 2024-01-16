part of 'expense_action.dart';

class DeleteExpenseAction extends ExpenseAction {
  DeleteExpenseAction(super.expense);

  @override
  IconData get icon => Icons.delete;

  @override
  String get name => 'Delete';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  @protected
  FutureOr<void> handle(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Delete expense',
        text:
            'Are you sure you want to delete this expense and all of its items?',
      ),
    );

    final expensesCubit = context.read<ExpensesCubit>();
    if (confirmed == true) expensesCubit.deleteExpense(expense.id);
  }
}
