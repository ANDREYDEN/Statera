import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/payment.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
import 'package:statera/ui/widgets/listItems/payment_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/helpers.dart';

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
    var authVm = Provider.of<AuthenticationViewModel>(context);

    if (groupId == null || otherMemberId == null) {
      return PageScaffold(child: Text("Something went wrong"));
    }

    return CustomStreamBuilder<Author>(
        stream: Firestore.instance
            .getGroupMemberStream(groupId: groupId, memberId: otherMemberId!),
        builder: (context, otherMember) {
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
                CustomStreamBuilder<Group>(
                  stream: Firestore.instance.groupStream(groupId),
                  builder: (context, group) {
                    final payment =
                        group.balance[authVm.user.uid]![otherMemberId]!;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        toStringPrice(payment),
                        style: TextStyle(fontSize: 32),
                      ),
                    );
                  },
                ),
                Flexible(
                  child: CustomStreamBuilder<List<Payment>>(
                    stream: Firestore.instance.paymentsStream(
                      groupId: groupId,
                      payerIds: [otherMemberId, authVm.user.uid],
                    ),
                    builder: (context, payments) {
                      if (payments.isEmpty) {
                        return ListEmpty(text: "Payment History is empty");
                      }
                      return ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          return PaymentListItem(payment: payments[index]);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          );
        });
  }
}
