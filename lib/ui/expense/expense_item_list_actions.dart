import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_scan_dialog.dart';
import 'package:statera/ui/expense/items/item_action.dart';
import 'package:statera/ui/widgets/buttons/large_action_button.dart';

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

    final addNewItemButton = LargeActionButton(
      onPressed: () => UpsertItemAction().safeHandle(context),
      title: 'Add Item',
      description: 'Start by adding the first item',
      icon: Icons.add,
    );

    final scanReceiptButton = LargeActionButton(
      onPressed: () => ReceiptScanDialog(expense: expense).show(context),
      title: 'Upload Receipt',
      description: 'Fill out the expense by taking a photo of a receipt',
      icon: Icons.photo_camera,
      width: 300,
    );

    return Or(
      axis: isWide ? Axis.horizontal : Axis.vertical,
      children: [
        if (expenseCanBeUpdated) addNewItemButton,
        if (showReceiptScannerButton) scanReceiptButton
      ],
    );
  }
}

class Or extends StatelessWidget {
  final List<Widget> children;
  final Axis axis;

  const Or({super.key, required this.children, this.axis = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return SizedBox.shrink();
    if (children.length == 1) return children[0];

    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: children[0]),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: axis == Axis.horizontal ? 10.0 : 0,
            vertical: axis == Axis.vertical ? 10.0 : 0,
          ),
          child: Center(
            child: Text(
              'or',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 24,
              ),
            ),
          ),
        ),
        Flexible(child: children[1])
      ],
    );
  }
}
