import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/payments/payments_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/owing_builder.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class PaymentListBody extends StatelessWidget {
  final String otherMemberId;

  const PaymentListBody({
    Key? key,
    required this.otherMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return GroupBuilder(builder: (context, group) {
      return OwingBuilder(builder: (context, otherMemberId) {
        return BlocProvider<PaymentsCubit>(
          key: Key(otherMemberId),
          create: (context) => PaymentsCubit(context.read<PaymentService>())
            ..load(groupId: group.id!, uid: uid, otherUid: otherMemberId),
          child: BlocConsumer<PaymentsCubit, PaymentsState>(
            listener: (context, state) {
              if (state is PaymentsLoaded) {
                Future.delayed(Duration(milliseconds: 500), () async {
                  final paymentsCubit = context.read<PaymentsCubit>();
                  await paymentsCubit.view(uid);
                });
              }
            },
            builder: (context, state) {
              if (state is PaymentsLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is PaymentsError) {
                return Center(child: Text(state.error));
              }

              if (state is PaymentsLoaded) {
                final payments = state.payments;

                if (payments.isEmpty) {
                  return ListEmpty(text: 'Payment History is empty');
                }

                return ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    return PaymentListItem(payment: payments[index]);
                  },
                );
              }

              return Container();
            },
          ),
        );
      });
    });
  }
}
