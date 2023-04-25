import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
import 'package:statera/ui/widgets/list_empty.dart';

import '../../data/models/models.dart';

class PaymentListBody extends StatelessWidget {
  final String otherMemberId;

  const PaymentListBody({
    Key? key,
    required this.otherMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    final paymentService = context.watch<PaymentService>();

    return GroupBuilder(builder: (context, group) {
      return CustomStreamBuilder<List<Payment>>(
        stream: paymentService.paymentsStream(
          groupId: group.id,
          userId1: otherMemberId,
          userId2: authBloc.uid,
        ),
        builder: (context, payments) {
          if (payments.isEmpty) {
            return ListEmpty(text: 'Payment History is empty');
          }

          payments.sort((Payment payment1, Payment payment2) {
            if (payment1.timeCreated == null) {
              return 1;
            }
            if (payment2.timeCreated == null) {
              return -1;
            }
            return payment1.timeCreated!.isAfter(payment2.timeCreated!)
                ? -1
                : 1;
          });

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              return PaymentListItem(payment: payments[index]);
            },
          );
        },
      );
    });
  }
}
