import 'package:flutter/material.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class SettleDebtDialog extends StatelessWidget {
  final String contactName;
  final double totalDebt;

  const SettleDebtDialog({
    super.key,
    required this.contactName,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final amount =
        '${Group.kdefaultCurrencySign}${totalDebt.abs().toStringAsFixed(2)}';
    final verb = totalDebt > 0 ? 'paid' : 'received';
    final direction = totalDebt > 0 ? 'to' : 'from';

    return AlertDialog(
      title: const Text('Settle Debt'),
      content: Text(
        'Please confirm that you $verb $amount $direction $contactName. This action will settle the balance across all shared groups.',
      ),
      actions: [
        CancelButton(),
        FilledButton(
          // TODO: settle the debt across all shared groups
          onPressed: () => Navigator.pop(context),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
