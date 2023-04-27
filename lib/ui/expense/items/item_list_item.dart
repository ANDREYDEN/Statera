import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/expense/items/item_decisions.dart';
import 'package:statera/ui/widgets/price_text.dart';

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

  @override
  Widget build(BuildContext context) {
    final uid = context.select((AuthBloc authBloc) => authBloc.uid);

    return Column(
      children: [
        ListTile(
          leading: item.isDeniedByAll
              ? Tooltip(
                  message: 'This item was not marked by any of the assignees',
                  // child: Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 2, left: 4, right: 4),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                      ),
                    ),
                  ),
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
                PriceText(
                  value: item.value,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  withTaxPostfix: expenseTax != null && item.isTaxable,
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
