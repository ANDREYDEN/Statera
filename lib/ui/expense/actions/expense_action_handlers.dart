import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/upsert_item_dialog.dart';

handleItemUpsert(BuildContext context, {Item? intialItem}) {
  final expenseBloc = context.read<ExpenseBloc>();

  showDialog(
    context: context,
    builder: (context) => UpsertItemDialog(
      intialItem: intialItem,
      expenseBloc: expenseBloc,
    ),
  );
}
