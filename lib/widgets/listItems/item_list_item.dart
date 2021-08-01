import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class ItemListItem extends StatelessWidget {
  final Item item;

  final void Function(ProductDecision) onDecisionTaken;

  const ItemListItem({
    Key? key,
    required this.item,
    required this.onDecisionTaken,
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
                )),
                Text(item.valueString),
              ],
            ),
          ),
          SizedBox(width: 10),
          VerticalDivider(thickness: 1, indent: 10, endIndent: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () =>
                    this.onDecisionTaken(ProductDecision.Confirmed),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  primary: authVm.hasConfirmed(item)
                      ? Colors.green[400]
                      : Colors.grey[300],
                ),
                child: Icon(Icons.check, color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () => this.onDecisionTaken(ProductDecision.Denied),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  primary: authVm.hasDenied(item)
                      ? Colors.red[400]
                      : Colors.grey[300],
                  padding: EdgeInsets.all(0),
                ),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}
