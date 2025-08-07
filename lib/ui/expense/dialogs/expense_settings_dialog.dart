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
  late Expense updatedExpense;

  @override
  void initState() {
    updatedExpense = widget.expense;
    super.initState();
  }

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
          label: 'Apply tax to items',
          initialData: widget.expense.settings.tax != null,
        ),
        FieldData(
          id: 'tax',
          label: 'Tax',
          initialData: (widget.expense.settings.tax ?? .13) * 100,
          formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
          validators: [FieldData.constrainedDoubleValidator(0, 100)],
          isDisabled: (fields) => fields['is_taxable'] == false,
          suffixIcon: Icons.percent,
        ),
        FieldData(
          id: 'itemsAreTaxableByDefault',
          label: 'Items are taxable by default',
          initialData: widget.expense.settings.itemsAreTaxableByDefault,
          isDisabled: (fields) => fields['is_taxable'] == false,
        ),
        FieldData(
          id: 'has_tip',
          label: 'Add tip to expense',
          initialData: widget.expense.settings.tip != null,
        ),
        FieldData(
          id: 'tip',
          label: 'Tip',
          initialData: (widget.expense.settings.tip ?? 0.15) * 100,
          formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
          validators: [FieldData.constrainedDoubleValidator(0, 100)],
          isDisabled: (fields) => fields['has_tip'] == false,
          suffixIcon: Icons.percent,
        ),
      ],
      onSubmit: (values) async {
        updatedExpense.settings.acceptNewMembers =
            values['automaticallyAddNewMembers'];
        updatedExpense.settings.showItemDecisions = values['showItemDecisions'];
        if (values['is_taxable']) {
          widget.expense.settings.tax = values['tax']! / 100;
          widget.expense.settings.itemsAreTaxableByDefault =
              values['itemsAreTaxableByDefault']!;
        } else {
          updatedExpense.settings.tax = null;
        }
        if (values['has_tip']) {
          widget.expense.settings.tip = values['tip']! / 100;
        } else {
          widget.expense.settings.tip = null;
        }
      },
    );
  }
}
