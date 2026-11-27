import 'package:flutter/material.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/payments/payment_list_header/current_debt.dart';
import 'package:statera/ui/payments/payment_list_header/header_avatar.dart';
import 'package:statera/ui/widgets/payment_info.dart';
import 'package:statera/ui/widgets/payment_info_loading.dart';
import 'package:statera/ui/payments/payment_list_header/payment_list_actions.dart';
import 'package:statera/ui/styling/index.dart';

class PaymentListHeader extends StatelessWidget {
  final String otherMemberId;

  const PaymentListHeader({Key? key, required this.otherMemberId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.s_8),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l_20),
        child: Column(
          children: [
            Row(
              children: [
                HeaderAvatar(otherMemberId: otherMemberId),
                const SizedBox(width: Spacing.m_10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrentDebt(otherMemberId: otherMemberId),
                      GroupBuilder(
                        builder: (context, group) {
                          final otherMember = group.getMember(otherMemberId);
                          return PaymentInfo(user: otherMember);
                        },
                        loadingWidget: PaymentInfoLoading(),
                        loadOnError: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.l_20),
            PaymentListActions(otherMemberId: otherMemberId),
          ],
        ),
      ),
    );
  }
}
