import 'package:flutter/material.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_scan_dialog.dart';
import 'package:statera/ui/expense/expense_builder.dart';

class ReceiptScanButton extends StatelessWidget {
  const ReceiptScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpenseBuilder(builder: (context, expense) {
      return OutlinedButton.icon(
        onPressed: () => ReceiptScanDialog(expense: expense).show(context),
        label: Text('Upload Receipt'),
        icon: Icon(Icons.photo_camera),
      );
    });
  }
}
