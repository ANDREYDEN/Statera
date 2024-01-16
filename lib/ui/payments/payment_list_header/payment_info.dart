import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class PaymentInfo extends StatelessWidget {
  final String otherMemberId;

  const PaymentInfo({super.key, required this.otherMemberId});

  void _copyPaymentInfo(BuildContext context, String paymentInfo) async {
    ClipboardData clipData = ClipboardData(text: paymentInfo);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment info copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) {
        final otherMember = group.getMember(otherMemberId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Info:'),
            if (otherMember.paymentInfo?.isNotEmpty != true)
              Text('N/A')
            else
              Row(
                children: [
                  Flexible(
                    child: Text(
                      otherMember.paymentInfo!,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () =>
                          _copyPaymentInfo(context, otherMember.paymentInfo!),
                      child: Icon(Icons.copy, size: 16),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
      loadingWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Info:'),
          LoadingText(height: 16, width: 200),
        ],
      ),
      loadOnError: true,
    );
  }
}
