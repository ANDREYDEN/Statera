import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';

class ExpenseSettingsDialog extends StatefulWidget {
  final Expense expense;
  const ExpenseSettingsDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ExpenseSettingsDialog> createState() => _ExpenseSettingsDialogState();
}

class _ExpenseSettingsDialogState extends State<ExpenseSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return CRUDDialog(
      title: 'Settings',
      fields: [
        FieldData(
          id: 'automaticallyAddNewMembers',
          label: 'Automatically add new members to this expense',
          initialData: widget.expense.settings.acceptNewMembers,
        ),
        FieldData(
          id: 'showItemDecisions',
          label: 'Show how other people marked each item',
          initialData: widget.expense.settings.showItemDecisions,
        ),
        FieldData(
          id: 'is_taxable',
          label: 'Apply tax to each item',
          initialData: widget.expense.settings.tax != null,
        ),
        FieldData(
          id: 'tax',
          label: 'Amount of tax to apply to each item',
          initialData: widget.expense.settings.tax,
          formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
          validators: [FieldData.constrainedDoubleValidator(0, 1)],
        ),
      ],
      onSubmit: (values) async {
        widget.expense.settings.acceptNewMembers =
            values['automaticallyAddNewMembers'] == 'true';
        widget.expense.settings.showItemDecisions =
            values['showItemDecisions'] == 'true';
        if (values['is_taxable']) {
          widget.expense.settings.tax = double.parse(values['tax']!);
        } else {
          widget.expense.settings.tax = null;
        }
        Navigator.pop(context, true);
      },
    );
  }
}
