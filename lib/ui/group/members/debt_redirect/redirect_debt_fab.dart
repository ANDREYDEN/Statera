import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/utils/helpers.dart';

class RedirectDebtFAB extends StatelessWidget {
  final bool popOnSuccess;
  final Widget? loadingLabel;

  const RedirectDebtFAB({
    super.key,
    this.popOnSuccess = true,
    this.loadingLabel,
  });

  Future<void> _handleRedirect(
      BuildContext context, DebtRedirectionLoaded state) async {
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

    if (success && popOnSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
      builder: (context, state) {
        Widget label = Text('Redirect');

        if (state is DebtRedirectionLoading) {
          label = loadingLabel ?? CircularProgressIndicator();
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
