import 'package:flutter/material.dart';
import 'package:statera/ui/contact/contact_header/settle_debt_dialog.dart';

class SettleDebtButton extends StatelessWidget {
  final String contactName;
  final double? totalDebt;

  const SettleDebtButton({
    super.key,
    required this.contactName,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: totalDebt == null || totalDebt == 0
          ? null
          : () => showDialog(
              context: context,
              builder: (_) => SettleDebtDialog(
                contactName: contactName,
                totalDebt: totalDebt!,
              ),
            ),
      child: const Text('Settle Debt'),
    );
  }
}
