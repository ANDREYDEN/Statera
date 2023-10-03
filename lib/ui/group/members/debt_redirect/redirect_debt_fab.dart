import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/utils/helpers.dart';

class RedirectDebtFAB extends StatelessWidget {
  const RedirectDebtFAB({super.key});

  Future<void> _handleRedirect(
      BuildContext context, DebtRedirectionLoaded state) async {
    final uid = context.read<AuthBloc>().uid;
    final groupCubit = context.read<GroupCubit>();
    final debtRedirectionCubit = context.read<DebtRedirectionCubit>();

    final success = await snackbarCatch(
      context,
      () async {
        debtRedirectionCubit.startLoading();

        await Future.delayed(Duration(seconds: 1));
        throw Exception('Weird error');

        // TODO: create transaction
        late double owerPaymentAmount;
        late double authorPaymentAmount;
        late double redirectedDebt;
        groupCubit.update((group) {
          final (owerPaymentAmnt, authorPaymentAmnt, redirectedDbt) =
              group.redirect(
            authorUid: uid,
            owerUid: state.owerUid,
            receiverUid: state.receiverUid,
          );
          owerPaymentAmount = owerPaymentAmnt;
          authorPaymentAmount = authorPaymentAmnt;
          redirectedDebt = redirectedDbt;
        });
        await _createPayments(
          context,
          state,
          owerPaymentAmount,
          authorPaymentAmount,
          redirectedDebt,
        );
      },
      successMessage: 'Debt successfuly redirected',
    );

    debtRedirectionCubit.init(
      uid: uid,
      group: state.group,
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createPayments(
    BuildContext context,
    DebtRedirectionLoaded state,
    double owerPaymentAmount,
    double authorPaymentAmount,
    double redirectedDebt,
  ) async {
    final paymentService = context.read<PaymentService>();

    await paymentService.addPayment(Payment.fromRedirect(
      groupId: state.group.id!,
      authorId: state.uid,
      payerId: state.owerUid,
      receiverId: state.uid,
      amount: owerPaymentAmount,
    ));
    await paymentService.addPayment(Payment.fromRedirect(
      groupId: state.group.id!,
      authorId: state.uid,
      payerId: state.uid,
      receiverId: state.receiverUid,
      amount: authorPaymentAmount,
    ));
    await paymentService.addPayment(Payment.fromRedirect(
      groupId: state.group.id!,
      authorId: state.uid,
      payerId: state.receiverUid,
      receiverId: state.owerUid,
      amount: redirectedDebt,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
      builder: (context, state) {
        Widget label = Text('Redirect');

        if (state is DebtRedirectionLoading) {
          label = CircularProgressIndicator();
        }

        return FloatingActionButton.extended(
          label: label,
          onPressed: (state is DebtRedirectionLoaded)
              ? () => _handleRedirect(context, state)
              : null,
        );
      },
    );
  }
}
