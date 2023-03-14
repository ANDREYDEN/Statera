import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';
import 'package:statera/utils/utils.dart';

class UpsertItemDialog extends StatefulWidget {
  final Item? intialItem;
  final ExpenseBloc expenseBloc;

  UpsertItemDialog({Key? key, this.intialItem, required this.expenseBloc})
      : super(key: key);

  @override
  State<UpsertItemDialog> createState() => _UpsertItemDialogState();
}

class _UpsertItemDialogState extends State<UpsertItemDialog> {
  bool get addingItem => widget.intialItem == null;

  AuthBloc get authBloc => context.read<AuthBloc>();

  @override
  Widget build(BuildContext context) {
    final itemTaxableByDefault = widget.expenseBloc.state is ExpenseLoaded &&
        (widget.expenseBloc.state as ExpenseLoaded)
            .expense
            .settings
            .itemsAreTaxableByDefault;

    return CRUDDialog(
      title: addingItem ? 'Add Item' : 'Edit Item',
      fields: [
        FieldData(
          id: 'item_name',
          label: 'Item Name',
          initialData: widget.intialItem?.name ?? '',
          validators: [FieldData.requiredValidator],
        ),
        FieldData<double>(
          id: 'item_value',
          label: 'Item Value',
          initialData: widget.intialItem?.value ?? 0.0,
          validators: [FieldData.requiredValidator],
          formatters: [CommaReplacerTextInputFormatter()],
        ),
        FieldData(
          id: 'item_partition',
          label: 'Item Parts',
          initialData: widget.intialItem?.partition ?? 1,
          validators: [FieldData.requiredValidator],
          formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
          isAdvanced: true,
        ),
        if (widget.expenseBloc.state is ExpenseLoaded &&
            (widget.expenseBloc.state as ExpenseLoaded).expense.hasTax)
          FieldData(
            id: 'item_taxable',
            label: 'Apply tax to item',
            initialData: widget.intialItem?.isTaxable ?? itemTaxableByDefault,
            isAdvanced: true,
          ),
      ],
      onSubmit: (values) {
        final item = widget.intialItem ??
            Item(
              name: values['item_name']!,
              value: values['item_value']!,
            );
        item.name = values['item_name']!;
        item.value = values['item_value']!;
        item.isTaxable = values['item_taxable'] ?? false;
        var newPartition = values['item_partition']!;
        if (addingItem || newPartition != widget.intialItem!.partition) {
          item.resetAssigneeDecisions();
          item.partition = newPartition;
        }

        widget.expenseBloc.add(
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
    );
  }
}
