import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void handle(BuildContext context) {
    final expenseBloc = context.read<ExpenseBloc>();

    if (item is SimpleItem) {
      showDialog(
        context: context,
        builder: (context) => UpsertItemDialog(
          intialItem: item as SimpleItem,
          expenseBloc: expenseBloc,
        ),
      );
    }
  }
}
