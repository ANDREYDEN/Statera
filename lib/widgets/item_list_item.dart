import 'package:flutter/material.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/item.dart';

class ItemListItem extends StatelessWidget {
  final Item item;

  final void Function() onConfirm;
  final void Function() onDeny;

  const ItemListItem({
    Key? key,
    required this.item, required this.onConfirm, required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(item.name),
          Text(item.valueString),
          Row(
            children: [
              IconButton(
                onPressed: this.onConfirm,
                icon: Icon(
                  Icons.check,
                  color:
                      item.assigneeDecision("asd") == ExpenseDecision.Confirmed
                          ? Colors.green
                          : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: this.onDeny,
                icon: Icon(
                  Icons.close,
                  color: item.assigneeDecision("asd") == ExpenseDecision.Denied
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
