import 'package:flutter/material.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list_body.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class PaymentListPage extends StatelessWidget {
  static const String route = "/payments";

  const PaymentListPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OwingBuilder(
      builder: (context, otherMemberId) {
        return GroupBuilder(
          builder: (context, group) {
            var otherMember = group.getMember(otherMemberId);

            return PageScaffold(
              title: "${otherMember.name} payments",
              child: PaymentListBody(),
            );
          },
        );
      },
    );
  }
}
