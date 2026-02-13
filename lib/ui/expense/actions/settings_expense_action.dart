part of 'expense_action.dart';

class SettingsExpenseAction extends ExpenseAction {
  SettingsExpenseAction(super.expense);

  @override
  IconData get icon => Icons.settings;

  @override
  String get name => 'Settings';

  @override
  @protected
  Future<void> handle(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();
    final updatedExpense = await showDialog<Expense>(
      context: context,
      builder: (_) => ExpenseSettingsDialog(expense: expense),
    );

    if (updatedExpense == null) return;

    expenseBloc.add(
      UpdateRequested(issuerUid: authBloc.uid, updatedExpense: updatedExpense),
    );
  }
}
