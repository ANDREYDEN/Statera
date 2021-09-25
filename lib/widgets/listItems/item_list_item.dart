import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/progress_bar.dart';

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
    var authVm = Provider.of<AuthenticationViewModel>(context, listen: false);
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
                Text(item.valueString),
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
                      onPressed: () =>
                          this.onChangePartition(authVm.getItemParts(item) - 1),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: !authVm.hasDecidedOn(item)
                            ? Colors.grey[300]
                            : authVm.hasDenied(item)
                                ? Colors.red[400]
                                : Colors.grey[500],
                        padding: EdgeInsets.all(0),
                      ),
                      child: Icon(
                        !authVm.hasDecidedOn(item) || !item.isPartitioned
                            ? Icons.close
                            : authVm.hasDenied(item)
                                ? Icons.close
                                : Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                        "${authVm.hasDecidedOn(item) ? authVm.getItemParts(item) : '-'}/${item.partition}"),
                    ElevatedButton(
                      onPressed: () =>
                          this.onChangePartition(authVm.getItemParts(item) + 1),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: !authVm.hasDecidedOn(item)
                            ? Colors.grey[300]
                            : item.undefinedParts == 0 &&
                                    authVm.hasConfirmed(item)
                                ? Colors.green[400]
                                : Colors.grey[500],
                      ),
                      child: Icon(
                        !authVm.hasDecidedOn(item) || !item.isPartitioned
                            ? Icons.check
                            : item.undefinedParts == 0 &&
                                    authVm.hasConfirmed(item)
                                ? Icons.check
                                : Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (item.isPartitioned)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: ProgressBar(
                      progress: item.confirmedParts,
                      total: item.partition,
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
