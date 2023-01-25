import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/dialogs/expense_dialogs.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/utils/utils.dart';

handleSettingsClick(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  final expenseBloc = context.read<ExpenseBloc>();

  expenseBloc.add(
    UpdateRequested(
      issuer: authBloc.user,
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
  final authBloc = context.read<AuthBloc>();
  final expenseBloc = context.read<ExpenseBloc>();
  final addingItem = intialItem == null;

  showDialog(
    context: context,
    builder: (context) => CRUDDialog(
      title: addingItem ? 'Add Item' : 'Edit Item',
      fields: [
        FieldData(
          id: 'item_name',
          label: 'Item Name',
          initialData: intialItem?.name,
          validators: [FieldData.requiredValidator],
        ),
        FieldData(
          id: 'item_value',
          label: 'Item Value',
          initialData: intialItem?.value,
          validators: [FieldData.requiredValidator],
          formatters: [CommaReplacerTextInputFormatter()],
        ),
        FieldData(
          id: 'item_partition',
          label: 'Item Parts',
          initialData: intialItem?.partition ?? 1,
          validators: [FieldData.requiredValidator],
          formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
          isAdvanced: true,
        ),
      ],
      onSubmit: (values) {
        final newItem = intialItem ?? Item(name: '', value: 0);
        newItem.name = values['item_name']!;
        newItem.value = double.parse(values['item_value']!);
        var newPartition = int.parse(values['item_partition']!);
        if (addingItem || newPartition != intialItem!.partition) {
          newItem.resetAssigneeDecisions();
          newItem.partition = newPartition;
        }

        expenseBloc.add(
          UpdateRequested(
            issuer: authBloc.user,
            update: (expense) {
              if (addingItem) {
                expense.addItem(newItem);
              } else {
                expense.updateItem(newItem);
              }
            },
          ),
        );
      },
      allowAddAnother: addingItem,
    ),
  );
}
