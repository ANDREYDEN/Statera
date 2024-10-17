import 'package:flutter/material.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/store.dart';

class StoreInput extends StatelessWidget {
  final ValueNotifier<Store?> controller;

  StoreInput({super.key, ValueNotifier<Store?>? controller})
      : this.controller = controller ?? ValueNotifier(Store.other);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Store>(
      value: controller.value,
      onChanged: (store) {
        controller.value = store;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Store',
      ),
      items: Store.values
          .map((store) =>
              DropdownMenuItem(child: Text(store.title), value: store))
          .toList(),
    );
  }
}
