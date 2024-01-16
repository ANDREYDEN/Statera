import 'package:flutter/material.dart';
import 'package:statera/ui/payments/payment_list_header/current_debt.dart';
import 'package:statera/ui/payments/payment_list_header/header_avatar.dart';
import 'package:statera/ui/payments/payment_list_header/payment_info.dart';
import 'package:statera/ui/payments/payment_list_header/payment_list_actions.dart';

class PaymentListHeader extends StatelessWidget {
  final String otherMemberId;

  const PaymentListHeader({
    Key? key,
    required this.otherMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                HeaderAvatar(otherMemberId: otherMemberId),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrentDebt(otherMemberId: otherMemberId),
                      PaymentInfo(otherMemberId: otherMemberId),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PaymentListActions(otherMemberId: otherMemberId),
          ],
        ),
      ),
    );
  }
}
