import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/expense/buttons/new_item_button.dart';
import 'package:statera/ui/expense/buttons/receipt_scan_button.dart';
import 'package:statera/ui/platform_context.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class EmptyExpenseItemsList extends StatelessWidget {
  final Expense expense;

  const EmptyExpenseItemsList({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final platformContext = context.read<PlatformContext>();

    final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);
    final showReceiptScannerButton =
        platformContext.isWeb || !platformContext.isMacOS;

    return ListEmpty(
      text: expenseCanBeUpdated
          ? 'Add items to this expense'
          : 'There are no items in this expense yet',
      actions: expenseCanBeUpdated
          ? [NewItemButton(), if (showReceiptScannerButton) ReceiptScanButton()]
          : [],
    );
  }
}
