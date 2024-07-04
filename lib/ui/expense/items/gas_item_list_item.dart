import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';

class GasItemListItem extends ItemListItem {
  late final GasItem item;

  GasItemListItem({
    super.key,
    required GasItem item,
    super.showDecisions,
    required super.onChangePartition,
    super.onLongPress,
    super.expenseTax,
  }) : super(item: item) {
    this.item = item;
  }

  @override
  Widget renderPrice(BuildContext context) {
    final priceWidget = super.renderPrice(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        priceWidget,
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
    );
  }
}
