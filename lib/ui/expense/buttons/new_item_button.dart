import 'package:flutter/material.dart';
import 'package:statera/ui/expense/items/item_action.dart';

class NewItemButton extends StatelessWidget {
  const NewItemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => UpsertItemAction().safeHandle(context),
      label: Text('Add Item'),
      icon: Icon(Icons.add),
    );
  }
}
