import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/contact/contact_header/settle_debt_dialog.dart';

class SettleDebtButton extends StatelessWidget {
  final CustomUser contact;
  final double totalDebt;
  final bool hasBalanceToSettle;

  const SettleDebtButton({
    super.key,
    required this.contact,
    required this.totalDebt,
    required this.hasBalanceToSettle,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: hasBalanceToSettle
          ? () => showDialog(
              context: context,
              builder: (_) =>
                  SettleDebtDialog(contact: contact, totalDebt: totalDebt),
            )
          : null,
      child: const Text('Settle Debt'),
    );
  }
}
