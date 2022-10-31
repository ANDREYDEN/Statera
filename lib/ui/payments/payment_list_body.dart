import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/payments/payments_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/price_text.dart';

import '../../data/models/models.dart';

class PaymentListBody extends StatelessWidget {
  const PaymentListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return OwingBuilder(
      loadingWidget: ListEmpty(text: 'Pick a group member first'),
      builder: (context, otherMemberId) {
        return GroupBuilder(
          builder: (context, group) {
            final otherMember = group.getUser(otherMemberId);
            final balance = group.balance[authBloc.uid]![otherMemberId]!;

            return Column(
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
                              currentUid: authBloc.uid,
                              payment: Payment(
                                groupId: group.id,
                                payerId: authBloc.uid,
                                receiverId: otherMemberId,
                                value: balance.abs(),
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
                              ),
                            ),
                          ),
                          child: Text('Receive'),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: BlocBuilder<PaymentsCubit, PaymentsState>(
                    builder: (context, paymentsState) {
                      if (paymentsState is PaymentsLoading) {
                        return Center(child: Loader());
                      }

                      if (paymentsState is PaymentsError) {
                        return Center(
                          child: Text(
                            paymentsState.error,
                            style: TextStyle(
                              color: Theme.of(context).errorColor,
                            ),
                          ),
                        );
                      }

                      if (paymentsState is PaymentsLoaded) {
                        final payments = paymentsState.payments;

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
                          return payment1.timeCreated!
                                  .isAfter(payment2.timeCreated!)
                              ? -1
                              : 1;
                        });

                        return ListView(
                          children: payments
                              .map((p) => PaymentListItem(payment: p))
                              .toList(),
                        );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
