import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/price_text.dart';

class RedirectArrow extends StatelessWidget {
  final double value;
  final Color? color;

  const RedirectArrow({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_right_alt_rounded,
          size: 60,
          color: value == 0 ? Colors.grey : color,
        ),
        PriceText(value: value),
      ],
    );
  }
}
