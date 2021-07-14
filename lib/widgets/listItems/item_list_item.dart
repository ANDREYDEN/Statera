import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/item.dart';
import 'package:statera/viewModels/authentication_vm.dart';

class ItemListItem extends StatelessWidget {
  final Item item;

  final void Function() onConfirm;
  final void Function() onDeny;

  const ItemListItem({
    Key? key,
    required this.item,
    required this.onConfirm,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context, listen: false);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.name)),
                Text(item.valueString),
              ],
            ),
          ),
          SizedBox(width: 20),
          Row(
            children: [
              Container(
                color: authVm.hasConfirmed(item) ? Colors.green : Colors.white,
                child: IconButton(
                  onPressed: this.onConfirm,
                  icon: Icon(
                    Icons.check,
                    color:
                        authVm.hasConfirmed(item) ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Container(
                color: authVm.hasDenied(item) ? Colors.red : Colors.white,
                child: IconButton(
                  onPressed: this.onDeny,
                  icon: Icon(
                    Icons.close,
                    color: authVm.hasDenied(item) ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
