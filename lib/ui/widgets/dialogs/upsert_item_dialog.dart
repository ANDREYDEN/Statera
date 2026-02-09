import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';
import 'package:statera/utils/utils.dart';

class UpsertItemDialog extends StatelessWidget {
  final Item? initialItem;
  final Expense expense;

  UpsertItemDialog({Key? key, this.initialItem, required this.expense})
    : super(key: key);

  R initialItemProperty<T extends Item, R>(
    R? Function(T item) selector, {
    required R or,
  }) {
    final tempItem = initialItem;
    if (tempItem is! T) return or;

    return selector(tempItem) ?? or;
  }

  @override
  build(BuildContext context) {
    bool addingItem = initialItem == null;

    final bool itemTaxableByDefault = expense.settings.itemsAreTaxableByDefault;

    final bool itemHasTax = expense.hasTax;

    final simpleItemFields = [
      FieldData<double>(
        id: 'item_value',
        label: 'Item Value',
        initialData: initialItemProperty((SimpleItem i) => i.value, or: 0.0),
        validators: [FieldData.requiredValidator],
        formatters: [CommaReplacerTextInputFormatter()],
      ),
    ];

    final gasItemFields = [
      FieldData<double>(
        id: 'item_distance',
        label: 'Distance',
        initialData: initialItemProperty((GasItem i) => i.distance, or: 0.0),
        validators: [FieldData.requiredValidator],
        formatters: [CommaReplacerTextInputFormatter()],
      ),
      FieldData<double>(
        id: 'item_gas_price',
        label: 'Gas Price (\$/L)',
        initialData: initialItemProperty((GasItem i) => i.gasPrice, or: 0.0),
        validators: [FieldData.requiredValidator],
        formatters: [CommaReplacerTextInputFormatter()],
      ),
      FieldData<double>(
        id: 'item_consumption',
        label: 'Consumption (L/100km)',
        initialData: initialItemProperty((GasItem i) => i.consumption, or: 0.0),
        validators: [FieldData.requiredValidator],
        formatters: [CommaReplacerTextInputFormatter()],
      ),
    ];

    final itemFieldsMap = {'simple': simpleItemFields, 'gas': gasItemFields};

    return CRUDDialog.segmented(
      title: addingItem ? 'Add Item' : 'Edit Item',
      segmentSelectionEnabled: addingItem,
      initialSelection: initialItem?.type.name,
      segments: [
        ButtonSegment(value: 'simple', label: Text('Simple')),
        ButtonSegment(
          value: 'gas',
          label: Text('Gas'),
          icon: Icon(Icons.local_gas_station),
        ),
      ],
      fieldsMap: itemFieldsMap.map(
        (segmentValue, itemFields) => MapEntry(segmentValue, [
          FieldData(
            id: 'item_name',
            label: 'Item Name',
            initialData: initialItem?.name ?? '',
            validators: [FieldData.requiredValidator],
          ),
          ...itemFields,
          FieldData(
            id: 'item_partition',
            label: 'Item Parts',
            initialData: initialItem?.partition ?? 1,
            validators: [FieldData.requiredValidator],
            formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
            isAdvanced: true,
          ),
          if (itemHasTax)
            FieldData(
              id: 'item_taxable',
              label: 'Apply tax to item',
              initialData: initialItem?.isTaxable ?? itemTaxableByDefault,
              isAdvanced: true,
            ),
        ]),
      ),
      buildWarning: (fields) {
        final itemName = (fields['item_name'] ?? '') as String;

        final possibleTipNames = ['tip', 'tips'];
        if (possibleTipNames.contains(itemName.trim().toLowerCase())) {
          return 'Tips can be added in expense settings';
        }

        final possibleTaxNames = ['tax', 'taxes'];
        if (possibleTaxNames.contains(itemName.trim().toLowerCase())) {
          return 'Taxes can be added in expense settings';
        }

        return null;
      },
      onSubmit: (values) {
        Item item = initialItem ?? Item.fake();

        final isSimpleItem = values['item_value'] != null;
        if (isSimpleItem) {
          item =
              initialItem ??
              SimpleItem(
                name: values['item_name'],
                value: values['item_value'],
              );
          final simpleItem = item as SimpleItem;
          simpleItem.value = values['item_value'];
        }

        final isGasItem = values['item_distance'] != null;
        if (isGasItem) {
          item =
              initialItem ??
              GasItem(
                name: values['item_name'],
                distance: values['item_distance'],
                gasPrice: values['item_gas_price'],
                consumption: values['item_consumption'],
              );
          final gasItem = item as GasItem;
          gasItem.distance = values['item_distance'];
          gasItem.gasPrice = values['item_gas_price'];
          gasItem.consumption = values['item_consumption'];
        }

        item.name = values['item_name']!;
        item.isTaxable = values['item_taxable'] ?? false;
        var newPartition = values['item_partition']!;
        if (addingItem || newPartition != initialItem!.partition) {
          item.resetAssigneeDecisions();
          item.partition = newPartition;
        }

        return item;
      },
      allowAddAnother: addingItem,
    );
  }
}
