import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/contact/contact_header/settle_debt_dialog.dart';

class SettleDebtButton extends StatelessWidget {
  final CustomUser contact;
  final double? totalDebt;

  const SettleDebtButton({
    super.key,
    required this.contact,
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
                contact: contact,
                totalDebt: totalDebt!,
              ),
            ),
      child: const Text('Settle Debt'),
    );
  }
}
