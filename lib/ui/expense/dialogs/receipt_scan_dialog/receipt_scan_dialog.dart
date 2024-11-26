import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/expense/dialogs/receipt_scan_dialog/receipt_scan_body.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class ReceiptScanDialog extends StatefulWidget {
  final Expense expense;

  const ReceiptScanDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ReceiptScanDialog> createState() => _ReceiptScanDialogState();

  Future<void> show(BuildContext context) {
    final isWide = context.read<LayoutState>().isWide;
    if (isWide) {
      return showDialog(context: context, builder: (_) => this);
    }

    return Navigator.of(context).push(
      MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => this),
    );
  }
}

class _ReceiptScanDialogState extends State<ReceiptScanDialog> {
  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);
    if (isWide) {
      return AlertDialog(
        title: Text('Scan a receipt'),
        content: DialogWidth(child: ReceiptScanBody(expense: widget.expense)),
      );
    }

    return PageScaffold(
      title: 'Scan a receipt',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ReceiptScanBody(expense: widget.expense),
      ),
    );
  }
}
