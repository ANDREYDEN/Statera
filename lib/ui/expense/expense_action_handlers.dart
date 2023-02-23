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
  final item = intialItem ??
      Item(
        name: '',
        value: 0,
        isTaxable: expenseBloc.state is ExpenseLoaded &&
            (expenseBloc.state as ExpenseLoaded)
                .expense
                .settings
                .itemsAreTaxableByDefault,
      );

  showDialog(
    context: context,
    builder: (context) => CRUDDialog(
      title: addingItem ? 'Add Item' : 'Edit Item',
      fields: [
        FieldData(
          id: 'item_name',
          label: 'Item Name',
          initialData: item.name,
          validators: [FieldData.requiredValidator],
        ),
        FieldData(
          id: 'item_value',
          label: 'Item Value',
          initialData: item.value,
          validators: [FieldData.requiredValidator],
          formatters: [CommaReplacerTextInputFormatter()],
        ),
        FieldData(
          id: 'item_partition',
          label: 'Item Parts',
          initialData: item.partition,
          validators: [FieldData.requiredValidator],
          formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
          isAdvanced: true,
        ),
        if (expenseBloc.state is ExpenseLoaded &&
            (expenseBloc.state as ExpenseLoaded).expense.hasTax)
          FieldData(
            id: 'item_taxable',
            label: 'Apply tax to item',
            initialData: item.isTaxable,
            isAdvanced: true,
          ),
      ],
      onSubmit: (values) {
        item.name = values['item_name']!;
        item.value = values['item_value']!;
        item.isTaxable = values['item_taxable'] ?? false;
        var newPartition = values['item_partition']!;
        if (addingItem || newPartition != intialItem!.partition) {
          item.resetAssigneeDecisions();
          item.partition = newPartition;
        }

        expenseBloc.add(
          UpdateRequested(
            issuer: authBloc.user,
            update: (expense) {
              if (addingItem) {
                expense.addItem(item);
              } else {
                expense.updateItem(item);
              }
            },
          ),
        );
      },
      allowAddAnother: addingItem,
    ),
  );
}
