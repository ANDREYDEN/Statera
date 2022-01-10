import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/progress_bar.dart';

class ItemListItem extends StatelessWidget {
  final Item item;

  final void Function(int) onChangePartition;

  const ItemListItem({
    Key? key,
    required this.item,
    required this.onChangePartition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc authBloc) => authBloc.state.user);

    if (user == null) return Container();

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(item.name),
                  ),
                ),
                PriceText(value: item.value),
              ],
            ),
          ),
          SizedBox(width: 10),
          VerticalDivider(thickness: 1, indent: 5, endIndent: 5),
          IntrinsicWidth(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => this.onChangePartition(
                          item.getAssigneeParts(user.uid) - 1),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: !item.isMarkedBy(user.uid)
                            ? Colors.grey[300]
                            : item.isMarkedBy(user.uid) &&
                                    item.getAssigneeParts(user.uid) == 0
                                ? Colors.red[400]
                                : Colors.grey[500],
                        padding: EdgeInsets.all(0),
                      ),
                      child: Icon(
                        !item.isMarkedBy(user.uid) || !item.isPartitioned
                            ? Icons.close
                            : item.isMarkedBy(user.uid) &&
                                    item.getAssigneeParts(user.uid) == 0
                                ? Icons.close
                                : Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                        "${item.isMarkedBy(user.uid) ? item.getAssigneeParts(user.uid) : '-'}/${item.partition}"),
                    ElevatedButton(
                      onPressed: () => this.onChangePartition(
                          item.getAssigneeParts(user.uid) + 1),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: !item.isMarkedBy(user.uid)
                            ? Colors.grey[300]
                            : item.undefinedParts == 0 &&
                                    item.isMarkedBy(user.uid) &&
                                    item.getAssigneeParts(user.uid) > 0
                                ? Colors.green[400]
                                : Colors.grey[500],
                      ),
                      child: Icon(
                        !item.isMarkedBy(user.uid) || !item.isPartitioned
                            ? Icons.check
                            : item.undefinedParts == 0 &&
                                    item.isMarkedBy(user.uid) &&
                                    item.getAssigneeParts(user.uid) > 0
                                ? Icons.check
                                : Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (item.isPartitioned)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ProgressBar(
                      progressParts: [
                        ProgressPart(
                          progress: item.confirmedParts -
                              item.getAssigneeParts(user.uid),
                          color: Colors.grey[500],
                        ),
                        ProgressPart(
                          progress: item.getAssigneeParts(user.uid),
                          color: Colors.green[300],
                        ),
                        ProgressPart(
                          progress: item.partition - item.confirmedParts,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                // SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );
  }
}
