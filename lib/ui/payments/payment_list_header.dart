import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class PaymentListHeader extends StatelessWidget {
  final String otherMemberId;

  const PaymentListHeader({
    Key? key,
    required this.otherMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return GroupBuilder(
      builder: (context, group) {
        final otherMember = group.getMember(otherMemberId);
        final balance = group.balance[authBloc.uid]![otherMemberId]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              author: otherMember,
              dimension: 100,
              margin: EdgeInsets.symmetric(vertical: 10),
            ),
            SizedBox(height: 8),
            PriceText(value: balance, textStyle: TextStyle(fontSize: 32)),
            Text('You owe'),
            SizedBox(height: 8),
            if (otherMember.paymentMethod?.isNotEmpty == true)
              Text('Payment method: ${otherMember.paymentMethod}'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => PaymentDialog(
                          group: group,
                          currentUid: authBloc.uid,
                          payment: Payment(
                            groupId: group.id,
                            payerId: authBloc.uid,
                            receiverId: otherMemberId,
                            value: balance.abs(),
                            oldPayerBalance: group.balance[authBloc.uid]
                                ?[otherMemberId],
                            newFor: [otherMemberId],
                          ),
                        ),
                      ),
                      child: Text('Pay'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => PaymentDialog(
                          group: group,
                          currentUid: authBloc.uid,
                          payment: Payment(
                            groupId: group.id,
                            payerId: otherMemberId,
                            receiverId: authBloc.uid,
                            value: balance.abs(),
                            oldPayerBalance: group.balance[otherMemberId]
                                ?[authBloc.uid],
                            newFor: [otherMemberId],
                          ),
                        ),
                      ),
                      child: Text('Receive'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
