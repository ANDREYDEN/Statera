import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/loading_text.dart';

class PaymentListActions extends StatelessWidget {
  final String otherMemberId;

  const PaymentListActions({super.key, required this.otherMemberId});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return GroupBuilder(
      builder: (context, group) {
        final balance = group.balance[authBloc.uid]![otherMemberId]!;

        return Row(
          children: [
            Expanded(
              child: FilledButton(
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
              child: FilledButton(
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
        );
      },
      loadingWidget: Row(
        children: [
          Expanded(child: LoadingText(height: 35, radius: 1000)),
          SizedBox(width: 16),
          Expanded(child: LoadingText(height: 35, radius: 1000)),
        ],
      ),
      loadOnError: true,
    );
  }
}
