import 'package:flutter/material.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class TotalDebtText extends StatelessWidget {
  final double totalDebt;
  final bool loading;

  const TotalDebtText({
    super.key,
    required this.totalDebt,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalDebt = this.totalDebt;

    if (loading) {
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
          '${Group.kdefaultCurrencySign}${totalDebt.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 32),
        ),
      ],
    );
  }
}
