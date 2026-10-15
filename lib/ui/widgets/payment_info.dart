import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/data/models/custom_user.dart';

class PaymentInfo extends StatelessWidget {
  final CustomUser user;

  const PaymentInfo({super.key, required this.user});

  Future<void> _copyPaymentInfo(
    BuildContext context,
    String paymentInfo,
  ) async {
    ClipboardData clipData = ClipboardData(text: paymentInfo);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment info copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Info:'),
        if (user.paymentInfo?.isNotEmpty != true)
          Text('N/A')
        else
          Row(
            children: [
              Flexible(
                child: Text(
                  user.paymentInfo!,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _copyPaymentInfo(context, user.paymentInfo!),
                  child: Icon(Icons.copy, size: 16),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
