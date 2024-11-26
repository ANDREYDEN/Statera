import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_scan_dialog.dart';
import 'package:statera/ui/expense/items/item_action.dart';

class ExpenseItemListActions extends StatelessWidget {
  final Expense expense;

  const ExpenseItemListActions({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);
    final showReceiptScannerButton = expense.hasNoItems &&
        expenseCanBeUpdated &&
        (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS);

    final addNewItemButton = FilledButton.icon(
      onPressed: () => UpsertItemAction().safeHandle(context),
      label: Text('Add Item'),
      icon: Icon(Icons.add),
    );

    final scanReceiptButton = ElevatedButton.icon(
      onPressed: () => ReceiptScanDialog(expense: expense).show(context),
      label: Text('Upload receipt'),
      icon: Icon(Icons.photo_camera),
    );

    return Or(children: [
      if (isWide && expenseCanBeUpdated) addNewItemButton,
      if (showReceiptScannerButton) scanReceiptButton
    ]);
  }
}

class Or extends StatelessWidget {
  final List<Widget> children;

  const Or({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return SizedBox.shrink();
    if (children.length == 1) return children[0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        children[0],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or'),
        ),
        children[1]
      ],
    );
  }
}
