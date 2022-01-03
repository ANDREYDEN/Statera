import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/payment_service.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
import 'package:statera/ui/widgets/dialogs/payment_dialog.dart';
import 'package:statera/ui/widgets/listItems/payment_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/price_text.dart';

class PaymentList extends StatelessWidget {
  static const String route = "/payments";

  final String? otherMemberId;
  final String? groupId;

  const PaymentList({
    Key? key,
    required this.otherMemberId,
    required this.groupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (groupId == null || otherMemberId == null) {
      return PageScaffold(child: Text("Something went wrong"));
    }

    var user = context.select((AuthBloc authBloc) => authBloc.state.user);

    if (user == null) {
      return PageScaffold(child: Text("Unauthorized"));
    }

    return CustomStreamBuilder<Group?>(
      stream: GroupService.instance.groupStream(this.groupId),
      builder: (context, group) {
        if (group == null) {
          return PageScaffold(child: Text('Group does not exist'));
        }

        final balance = group.balance[user.uid]![otherMemberId]!;
        var otherMember = group.getUser(this.otherMemberId!);
        return PageScaffold(
          title: "${otherMember.name} payments",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthorAvatar(
                author: otherMember,
                width: 100,
                margin: EdgeInsets.symmetric(vertical: 10),
              ),
              SizedBox(height: 8),
              PriceText(value: balance, textStyle: TextStyle(fontSize: 32)),
              Text('You owe'),
              SizedBox(height: 8),
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
                            currentUid: user.uid,
                            payment: Payment(
                              groupId: group.id,
                              payerId: user.uid,
                              receiverId: this.otherMemberId!,
                              value: balance.abs(),
                            ),
                          ),
                        ),
                        child: Text("Pay"),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => PaymentDialog(
                            group: group,
                            currentUid: user.uid,
                            payment: Payment(
                              groupId: group.id,
                              payerId: this.otherMemberId!,
                              receiverId: user.uid,
                              value: balance.abs(),
                            ),
                          ),
                        ),
                        child: Text("Receive"),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: CustomStreamBuilder<List<Payment>>(
                  stream: PaymentService.instance.paymentsStream(
                    groupId: groupId,
                    userId1: otherMemberId,
                    userId2: user.uid,
                  ),
                  builder: (context, payments) {
                    if (payments.isEmpty) {
                      return ListEmpty(text: "Payment History is empty");
                    }

                    payments.sort((Payment payment1, Payment payment2) {
                      if (payment1.timeCreated == null) {
                        return 1;
                      }
                      if (payment2.timeCreated == null) {
                        return -1;
                      }
                      return payment1.timeCreated!
                              .isAfter(payment2.timeCreated!)
                          ? -1
                          : 1;
                    });

                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        return PaymentListItem(
                          payment: payments[index],
                          receiverUid: user.uid,
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
