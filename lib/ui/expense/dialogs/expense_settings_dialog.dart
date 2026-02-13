import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';

class ExpenseSettingsDialog extends StatelessWidget {
  final Expense expense;

  const ExpenseSettingsDialog({Key? key, required this.expense})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CRUDDialog(
      title: 'Settings',
      fields: [
        FieldData(
          id: 'automaticallyAddNewMembers',
          label: 'Automatically add new members to this expense',
          initialData: expense.settings.acceptNewMembers,
        ),
        FieldData(
          id: 'showItemDecisions',
          label: 'Show how other people marked each item',
          initialData: expense.settings.showItemDecisions,
        ),
        FieldData(
          id: 'is_taxable',
          label: 'Apply tax to items',
          initialData: expense.settings.tax != null,
        ),
        FieldData(
          id: 'tax',
          label: 'Tax',
          initialData: (expense.settings.tax ?? .13) * 100,
          formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
          validators: [FieldData.constrainedDoubleValidator(0, 100)],
          isDisabled: (fields) => fields['is_taxable'] == false,
          suffixIcon: Icons.percent,
        ),
        FieldData(
          id: 'itemsAreTaxableByDefault',
          label: 'Items are taxable by default',
          initialData: expense.settings.itemsAreTaxableByDefault,
          isDisabled: (fields) => fields['is_taxable'] == false,
        ),
        FieldData(
          id: 'has_tip',
          label: 'Add tip to expense',
          initialData: expense.settings.tip != null,
        ),
        FieldData(
          id: 'tip',
          label: 'Tip',
          initialData: (expense.settings.tip ?? 0.15) * 100,
          formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
          validators: [FieldData.constrainedDoubleValidator(0, 100)],
          isDisabled: (fields) => fields['has_tip'] == false,
          suffixIcon: Icons.percent,
        ),
      ],
      onSubmit: (values) {
        final expenseSettings = ExpenseSettings(
          acceptNewMembers: values['automaticallyAddNewMembers'],
          showItemDecisions: values['showItemDecisions'],
          itemsAreTaxableByDefault: values['itemsAreTaxableByDefault'],
          tax: values['is_taxable'] ? values['tax']! / 100 : null,
          tip: values['has_tip'] ? values['tip']! / 100 : null,
        );

        return Expense.from(expense, settings: expenseSettings);
      },
    );
  }
}
