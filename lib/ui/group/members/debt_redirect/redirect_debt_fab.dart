import 'package:flutter/material.dart';
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

        // TODO: create transaction
        await _createPayments(context, state);
        groupCubit.update((group) => state.redirect.execute(group));
      },
      successMessage: 'Debt successfuly redirected',
    );

    debtRedirectionCubit.init(
      uid: uid,
      groupCubit: groupCubit,
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createPayments(
    BuildContext context,
    DebtRedirectionLoaded state,
  ) async {
    final paymentService = context.read<PaymentService>();

    final owerPaymentAmount = state.owerDebt - state.redirect.newOwerDebt;
    final authorPaymentAmount = state.authorDebt - state.redirect.newAuthorDebt;
    final redirectedDebt = state.redirect.redirectedBalance;

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
