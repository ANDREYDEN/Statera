import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
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
        // TODO: create transaction
        await debtRedirectionCubit.createPayments();
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
