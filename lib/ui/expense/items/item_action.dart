import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/upsert_item_dialog.dart';
import 'package:statera/ui/widgets/entity_action.dart';

abstract class ItemAction extends EntityAction {
  final Item? item;

  ItemAction({this.item});
}

class UpsertItemAction extends ItemAction {
  UpsertItemAction({super.item});

  @override
  IconData get icon => Icons.add;

  @override
  String get name => 'Upsert Item';

  @override
  @protected
  Future<void> handle(BuildContext context) async {
    await showDialog<Item>(
      context: context,
      builder: (_) => Provider.value(
        value: context.read<ExpenseBloc>(),
        child: UpsertItemDialog(
          initialItem: item == null ? null : Item.from(item!),
          onSubmit: (newItem) {
            final expenseBloc = context.read<ExpenseBloc>();

            final expenseState = expenseBloc.state;
            if (expenseState is! ExpenseLoaded) return;
            final expense = expenseState.expense;
            final updatedExpense = Expense.from(expense);
            if (item == null) {
              updatedExpense.addItem(newItem);
            } else {
              updatedExpense.updateItem(newItem);
            }

            expenseBloc.add(UpdateRequested(updatedExpense: updatedExpense));
          },
        ),
      ),
    );
  }
}
