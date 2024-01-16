import 'package:flutter/material.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list_body.dart';
import 'package:statera/ui/payments/payment_list_header/payment_list_header.dart';
import 'package:statera/ui/widgets/list_empty.dart';

/// Payment List represents the header with payment buttons and the payment history.
/// It is used in both the [GroupPage] and [PaymentListPage] widgets.
class PaymentList extends StatelessWidget {
  const PaymentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OwingBuilder(
      noneWidget: ListEmpty(text: 'Pick a group member first'),
      builder: (context, otherMemberId) {
        return Column(
          children: [
            PaymentListHeader(otherMemberId: otherMemberId),
            SizedBox(height: 10),
            Expanded(child: PaymentListBody(otherMemberId: otherMemberId)),
          ],
        );
      },
    );
  }
}
