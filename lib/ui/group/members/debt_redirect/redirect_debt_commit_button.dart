import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';

class RedirectDebtCommitButton extends StatelessWidget {
  const RedirectDebtCommitButton({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().uid;
    var groupCubit = context.read<GroupCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
          builder: (context, state) {
            if (state is! DebtRedirectionLoaded) {
              return CircularProgressIndicator();
            }

            return ElevatedButton(
              onPressed: () {
                groupCubit.update((group) => group.redirect(
                      authorUid: uid,
                      owerUid: state.owerUid,
                      receiverUid: state.receiverUid,
                    ));
                Navigator.pop(context);
              },
              child: Text('Redirect'),
            );
          },
        ),
      ),
    );
  }
}
