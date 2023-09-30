import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';

import 'debt_redirect_explainer_dialog.dart';

class RedirectDebtHeaderText extends StatelessWidget {
  const RedirectDebtHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtRedirectionCubit, DebtRedirectionState>(
      builder: (context, state) {
        if (state is DebtRedirectionImpossible) {
          return Text(
            "Looks like you ca't perfom debt redirection at this time.",
          );
        }
        if (state is DebtRedirectionOff) {
          return Text('Debt redirection is turned off for this group.');
        }

        return Column(
          children: [
            Text(
              'Looks like you can simplify some transactions! Here is the suggested redirection of debt, but you are free to choose any ower/receiver combination.',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DebtRedirectExplainerDialog(),
                  );
                },
                child: Text('Learn more about Debt Redirection'),
              ),
            ),
          ],
        );
      },
    );
  }
}
