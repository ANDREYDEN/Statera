import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
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
    final expenseBloc = context.read<ExpenseBloc>();
    final authBloc = context.read<AuthBloc>();

    final expenseState = expenseBloc.state;
    if (expenseState is! ExpenseLoaded) return;
    final expense = expenseState.expense;

    final updatedItem = await showDialog<Item>(
      context: context,
      builder: (context) => UpsertItemDialog(
        initialItem: item == null ? null : Item.from(item!),
        expense: expense,
      ),
    );

    if (updatedItem == null) return;

    final updatedExpense = Expense.from(expense);
    if (item == null) {
      updatedExpense.addItem(updatedItem);
    } else {
      updatedExpense.updateItem(updatedItem);
    }

    expenseBloc.add(
      UpdateRequested(issuerUid: authBloc.uid, updatedExpense: updatedExpense),
    );
  }
}
