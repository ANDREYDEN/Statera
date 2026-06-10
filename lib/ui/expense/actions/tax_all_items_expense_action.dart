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
    final tax = expense.settings.tax ?? kDefaultTax;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Add tax to all items',
        okText: 'Confirm',
        text: expense.hasTax
            ? 'This action will apply a tax of ${tax * 100}% to all items in this expense.'
            : 'This action will enable taxes for this expense and will apply a default tax of ${tax * 100}% to all items.',
      ),
    );
    if (confirmed != true) return;

    final expenseBloc = context.read<ExpenseBloc>();

    final updatedExpense = Expense.from(expense);
    updatedExpense.addTaxToAllItems();
    expenseBloc.add(UpdateRequested(updatedExpense: updatedExpense));
  }
}
