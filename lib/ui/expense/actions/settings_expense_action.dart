part of 'expense_action.dart';

class SettingsExpenseAction extends ExpenseAction {
  SettingsExpenseAction(super.expense);

  @override
  IconData get icon => Icons.settings;

  @override
  String get name => 'Settings';

  @override
  @protected
  FutureOr<void> handle(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuerUid: authBloc.uid,
        update: (expense) => showDialog(
          context: context,
          builder: (_) => ExpenseSettingsDialog(expense: expense),
        ),
      ),
    );
  }
}
