import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class PaymentInfoLoading extends StatelessWidget {
  const PaymentInfoLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('Payment Info:'), LoadingText(height: 16, width: 200)],
    );
  }
}
