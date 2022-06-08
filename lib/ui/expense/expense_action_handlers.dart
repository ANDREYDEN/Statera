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

handleNewItemClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Item",
        fields: [
          FieldData(
            id: "item_name",
            label: "Item Name",
            validators: [FieldData.requiredValidator],
          ),
          FieldData(
            id: "item_value",
            label: "Item Value",
            inputType: TextInputType.numberWithOptions(decimal: true),
            validators: [
              FieldData.requiredValidator,
              FieldData.doubleValidator
            ],
            formatters: [CommaReplacerTextInputFormatter()],
          ),
          FieldData(
            id: "item_partition",
            label: "Item Parts",
            inputType: TextInputType.number,
            initialData: 1,
            validators: [FieldData.requiredValidator, FieldData.intValidator],
            formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
            isAdvanced: true,
          ),
        ],
        onSubmit: (values) {
          expenseBloc.add(
            UpdateRequested(
              issuer: authBloc.user,
              update: (expense) {
                expense.addItem(Item(
                  name: values["item_name"]!,
                  value: double.parse(values["item_value"]!),
                  partition: int.parse(values["item_partition"]!),
                ));
              },
            ),
          );
        },
        allowAddAnother: true,
      ),
    );
  }