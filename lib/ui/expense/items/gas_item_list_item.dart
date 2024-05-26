import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/items/item_decisions.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/warning_icon.dart';

class GasItemListItem extends StatelessWidget {
  final GasItem item;
  final bool showDecisions;
  final void Function(int) onChangePartition;
  final void Function()? onLongPress;
  final double? expenseTax;

  const GasItemListItem({
    super.key,
    required this.item,
    required this.showDecisions,
    required this.onChangePartition,
    this.onLongPress,
    this.expenseTax,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.select((AuthBloc authBloc) => authBloc.uid);

    return Column(
      children: [
        ListTile(
          leading: item.isDeniedByAll
              ? Tooltip(
                  message: 'This item was not marked by any of the assignees',
                  child: WarningIcon(),
                )
              : null,
          title: Text(item.name),
          subtitle: (!showDecisions || item.confirmedParts == 0)
              ? null
              : ItemDecisions(item: item),
          trailing: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceText(
                      value: item.total,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      withTaxPostfix: expenseTax != null && item.isTaxable,
                    ),
                    Row(
                      children: [
                        Text(item.distance.toString()),
                        Text('km'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text('·'),
                        ),
                        Text(item.consumption.toString()),
                        Text('L/100km'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text('·'),
                        ),
                        Text(item.gasPrice.toString()),
                        Text('\$/L'),
                      ],
                    )
                  ],
                ),
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
