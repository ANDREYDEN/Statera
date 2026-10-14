import 'package:flutter/material.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class TotalDebtText extends StatelessWidget {
  final double? totalDebt;

  const TotalDebtText({super.key, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    final totalDebt = this.totalDebt;

    if (totalDebt == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total debt'),
          const LoadingText(height: 45, width: 100),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('You owe'),
        // TODO: figure out currency sign here
        Text(
          '${Group.kdefaultCurrencySign}${totalDebt.abs().toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 32),
        ),
      ],
    );
  }
}
