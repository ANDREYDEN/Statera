part of 'expense_action.dart';

class RevertExpenseAction extends ExpenseAction {
  RevertExpenseAction(super.expense);

  @override
  IconData get icon => Icons.undo;

  @override
  String get name => 'Revert';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  @protected
  handle(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Revert expense',
        text:
            'Are you sure you want to revert this expense? All members that took part in this expense will be refunded and the expense will become active again.',
      ),
    );

    if (confirmed == false) return;

    final groupCubit = context.read<GroupCubit>();
    final expensesCubit = context.read<ExpensesCubit>();

    final group = groupCubit.loadedState.group;

    await expensesCubit.revertExpense(expense, group);
  }
}
