import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/payments/payments_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/user_builder.dart';
import 'package:statera/ui/payments/payment_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class ContactPaymentListBody extends StatelessWidget {
  const ContactPaymentListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return UserBuilder(
      builder: (context, contact) {
        return BlocProvider<PaymentsCubit>(
          key: Key(contact.uid),
          create: (context) => PaymentsCubit(
            context.read<PaymentService>(),
            context.read<ErrorService>(),
          )..load(uid: uid, otherUid: contact.uid),
          child: _ContactPaymentListView(uid: uid),
        );
      },
    );
  }
}

class _ContactPaymentListView extends StatelessWidget {
  final String uid;

  const _ContactPaymentListView({required this.uid});

  void _markPaymentsAsViewed(BuildContext context) {
    final paymentsCubit = context.read<PaymentsCubit>();
    Future.delayed(const Duration(milliseconds: 500), () {
      paymentsCubit.view(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentsCubit, PaymentsState>(
      listener: (context, state) {
        if (state is PaymentsLoaded) _markPaymentsAsViewed(context);
      },
      builder: (context, state) {
        if (state is PaymentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PaymentsError) {
          return Center(child: Text(state.error));
        }

        final payments = (state as PaymentsLoaded).payments;

        if (payments.isEmpty) {
          return const ListEmpty(text: 'Payment History is empty');
        }

        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            return PaymentListItem(
              payment: payments[index],
              withGroupName: true,
            );
          },
        );
      },
    );
  }
}
