import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/gas_item.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/expense/items/gas_item_list_item.dart';
import 'package:statera/ui/expense/items/item_decisions.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/warning_icon.dart';

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
    final uid = context.select((AuthBloc authBloc) => authBloc.uid);

    final denyButtonBgColor = (() {
      if (!item.isMarkedBy(uid)) return Colors.grey[300];
      if (item.getAssigneeParts(uid) == 0) return Colors.red[400];
      return Colors.grey[500];
    })();

    final denyButtonColor = denyButtonBgColor == Colors.grey[300]
        ? Colors.grey[700]
        : Colors.white;

    final denyButtonIcon = (() {
      if (item.isPartitioned && item.getAssigneeParts(uid) > 0) {
        return Icons.remove_rounded;
      }
      return Icons.close_rounded;
    })();

    final acceptButtonBgColor = (() {
      if (!item.isMarkedBy(uid)) return Colors.grey[300];
      if (item.getAssigneeParts(uid) > 0) return Colors.green[400];
      return Colors.grey[500];
    })();

    final acceptButtonColor = acceptButtonBgColor == Colors.grey[300]
        ? Colors.grey[700]
        : Colors.white;

    final acceptButtonIcon = (() {
      if (item.isPartitioned &&
          item.undefinedParts > 0 &&
          item.getAssigneeParts(uid) > 0) {
        return Icons.add_rounded;
      }
      return Icons.check_rounded;
    })();

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
                IconButton(
                  onPressed: disabled
                      ? null
                      : () => this.onChangePartition(
                          item.getAssigneeParts(uid) - 1,
                        ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
                    backgroundColor: denyButtonBgColor,
                    foregroundColor: denyButtonColor,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[400],
                    padding: EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(denyButtonIcon),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.xs_5),
                  child: Visibility(
                    visible: item.partition > 1,
                    child: Text(
                      "${item.isMarkedBy(uid) ? item.getAssigneeParts(uid) : '-'}/${item.partition}",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: disabled
                      ? null
                      : () => this.onChangePartition(
                          item.getAssigneeParts(uid) + 1,
                        ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRad.s_10),
                    backgroundColor: acceptButtonBgColor,
                    foregroundColor: acceptButtonColor,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[400],
                    padding: EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(acceptButtonIcon),
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
