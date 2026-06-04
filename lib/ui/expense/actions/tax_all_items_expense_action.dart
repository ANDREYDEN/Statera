part of 'expense_action.dart';

class TaxAllItemsAction extends ExpenseAction {
  TaxAllItemsAction(super.expense);

  @override
  IconData get icon => Icons.monetization_on_rounded;

  @override
  String get name => 'Add tax to all items';

  @override
  @protected
  FutureOr<void> handle(BuildContext context) async {
    final tax = expense.settings.tax;

    if (tax == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Add tax to all items',
        text:
            'Are you sure you want to apply a tax of ${tax * 100}% to all items in this expense?',
      ),
    );
    if (confirmed != true) return;

    final expenseBloc = context.read<ExpenseBloc>();

    final updatedExpense = Expense.from(expense);
    updatedExpense.addTaxToAllItems();
    expenseBloc.add(UpdateRequested(updatedExpense: updatedExpense));
  }
}
