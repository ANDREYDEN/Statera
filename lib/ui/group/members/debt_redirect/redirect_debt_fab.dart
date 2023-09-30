import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';

class RedirectDebtFAB extends StatelessWidget {
  const RedirectDebtFAB({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          label: Text('Redirect'),
          onPressed: (state is DebtRedirectionLoaded)
              ? () {
                  groupCubit.update((group) {
                    group.redirect(
                      authorUid: uid,
                      owerUid: state.owerUid,
                      receiverUid: state.receiverUid,
                    );
                  });
                  Navigator.pop(context);
                }
              : null,
        );
      },
    );
  }
}
