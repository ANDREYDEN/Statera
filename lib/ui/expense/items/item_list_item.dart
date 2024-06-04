import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/expense/items/item_decisions.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/warning_icon.dart';

class ItemListItem extends StatelessWidget {
  final Item item;
  final bool showDecisions;
  final void Function(int) onChangePartition;
  final void Function()? onLongPress;
  final double? expenseTax;

  const ItemListItem({
    Key? key,
    required this.item,
    this.showDecisions = false,
    required this.onChangePartition,
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
                ElevatedButton(
                  onPressed: () =>
                      this.onChangePartition(item.getAssigneeParts(uid) - 1),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: !item.isMarkedBy(uid)
                        ? Colors.grey[300]
                        : item.isMarkedBy(uid) &&
                                item.getAssigneeParts(uid) == 0
                            ? Colors.red[400]
                            : Colors.grey[500],
                    padding: EdgeInsets.all(0),
                  ),
                  child: Icon(
                    !item.isMarkedBy(uid) || !item.isPartitioned
                        ? Icons.close_rounded
                        : item.isMarkedBy(uid) &&
                                item.getAssigneeParts(uid) == 0
                            ? Icons.close_rounded
                            : Icons.remove_rounded,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${item.isMarkedBy(uid) ? item.getAssigneeParts(uid) : '-'}/${item.partition}",
                ),
                ElevatedButton(
                  onPressed: () =>
                      this.onChangePartition(item.getAssigneeParts(uid) + 1),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: !item.isMarkedBy(uid)
                        ? Colors.grey[300]
                        : item.undefinedParts == 0 &&
                                item.isMarkedBy(uid) &&
                                item.getAssigneeParts(uid) > 0
                            ? Colors.green[400]
                            : Colors.grey[500],
                  ),
                  child: Icon(
                    !item.isMarkedBy(uid) || !item.isPartitioned
                        ? Icons.check_rounded
                        : item.undefinedParts == 0 &&
                                item.isMarkedBy(uid) &&
                                item.getAssigneeParts(uid) > 0
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                    color: Colors.white,
                  ),
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
