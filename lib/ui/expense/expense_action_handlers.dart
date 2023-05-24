import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/dialogs/expense_dialogs.dart';
import 'package:statera/ui/widgets/dialogs/upsert_item_dialog.dart';

handleSettingsClick(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  final expenseBloc = context.read<ExpenseBloc>();

  expenseBloc.add(
    UpdateRequested(
      issuerUid: authBloc.uid,
      update: (expense) async {
        await showDialog(
          context: context,
          builder: (_) => ExpenseSettingsDialog(expense: expense),
        );
      },
    ),
  );
}

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
