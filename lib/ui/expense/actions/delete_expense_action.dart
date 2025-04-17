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
    if (confirmed != true) return;

    final expenseBloc = context.read<ExpenseBloc>();
    final expensesCubit = context.read<ExpensesCubit>();

    expenseBloc.unload();
    await expensesCubit.deleteExpense(expense.id);
  }
}
