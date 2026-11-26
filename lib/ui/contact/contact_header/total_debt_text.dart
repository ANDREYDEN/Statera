import 'package:flutter/material.dart';
import 'package:statera/data/value_objects/aggregated_debt.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class TotalDebtText extends StatelessWidget {
  final AggregatedDebt? totalDebt;
  final bool conversionFailed;

  const TotalDebtText({
    super.key,
    required this.totalDebt,
    this.conversionFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalDebt = this.totalDebt;

    if (conversionFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total debt'),
          const Text('Unable to convert currencies'),
        ],
      );
    }

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
        Text(totalDebt.render(), style: const TextStyle(fontSize: 32)),
      ],
    );
  }
}
