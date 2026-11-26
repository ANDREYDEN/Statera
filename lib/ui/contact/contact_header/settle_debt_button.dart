import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/ui/contact/contact_header/settle_debt_dialog.dart';

class SettleDebtButton extends StatelessWidget {
  final CustomUser contact;
  final AggregatedDebt? totalDebt;

  const SettleDebtButton({
    super.key,
    required this.contact,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final totalDebt = this.totalDebt;
    final hasDebt = totalDebt != null && totalDebt.amount != 0;

    return FilledButton(
      onPressed: !hasDebt
          ? null
          : () => showDialog(
              context: context,
              builder: (_) => SettleDebtDialog(
                contact: contact,
                totalDebt: totalDebt,
              ),
            ),
      child: const Text('Settle Debt'),
    );
  }
}
