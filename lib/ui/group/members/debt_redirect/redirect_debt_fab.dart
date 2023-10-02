import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

class RedirectDebtFAB extends StatelessWidget {
  const RedirectDebtFAB({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();
    var paymentService = context.read<PaymentService>();

    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          label: Text('Redirect'),
          onPressed: (state is DebtRedirectionLoaded)
              ? () async {
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
                  Navigator.pop(context);
                }
              : null,
        );
      },
    );
  }
}
