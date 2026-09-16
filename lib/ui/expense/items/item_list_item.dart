import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/impersonation_cubit.dart';
import 'package:statera/data/models/gas_item.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/expense/items/gas_item_list_item.dart';
import 'package:statera/ui/expense/items/item_decisions.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/inputs/decision_buttons.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/warning_icon.dart';
import 'package:statera/utils/build_context_extensions.dart';

class ItemListItem extends StatelessWidget {
  final Item item;
  final void Function(int) onChangePartition;
  final bool disabled;
  final bool showDecisions;
  final void Function()? onLongPress;
  final double? expenseTax;

  const ItemListItem({
    Key? key,
    required this.item,
    required this.onChangePartition,
    this.disabled = false,
    this.showDecisions = false,
    this.onLongPress,
    this.expenseTax,
  }) : super(key: key);

  Widget? get leading {
    if (item.isDeniedByAll) {
      return Tooltip(
        message: 'This item was not marked by any of the assignees',
        child: WarningIcon(),
      );
    }

    if (item.isPartitioned && item.confirmedParts > item.partition) {
      return Tooltip(
        message:
            'More parts are marked (${item.confirmedParts}) than the total number of item parts (${item.partition})',
        child: WarningIcon(),
      );
    }

    return null;
  }

  Widget renderPrice(BuildContext context) {
    return PriceText(
      value: item.total,
      textStyle: Theme.of(context).textTheme.titleMedium,
      withTaxPostfix: expenseTax != null && item.isTaxable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUid = context.watchEffectiveUid();

    return Column(
      children: [
        ListTile(
          leading: leading,
          title: Text(item.name),
          subtitle: (!showDecisions || item.confirmedParts == 0)
              ? null
              : ItemDecisions(item: item),
          trailing: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                renderPrice(context),
                SizedBox(width: Spacing.m_10),
                DecisionButtons(
                  item: item,
                  uid: effectiveUid,
                  onChangePartition: onChangePartition,
                  disabled: disabled,
                ),
              ],
            ),
          ),
          onLongPress: onLongPress,
        ),
      ],
    );
  }
}

class ItemListItemFactory {
  static ItemListItem create({
    Key? key,
    required Item item,
    required void Function(int) onChangePartition,
    bool disabled = false,
    bool showDecisions = false,
    void Function()? onLongPress,
    double? expenseTax,
  }) {
    if (item is GasItem) {
      return GasItemListItem(
        item: item,
        onChangePartition: onChangePartition,
        disabled: disabled,
        showDecisions: showDecisions,
        onLongPress: onLongPress,
        expenseTax: expenseTax,
      );
    }
    return ItemListItem(
      item: item,
      onChangePartition: onChangePartition,
      disabled: disabled,
      showDecisions: showDecisions,
      onLongPress: onLongPress,
      expenseTax: expenseTax,
    );
  }
}
