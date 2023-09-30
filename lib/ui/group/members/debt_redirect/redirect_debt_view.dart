import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_commit_button.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_header_text.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_visual.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class RedirectDebtView extends StatelessWidget {
  final Group group;

  const RedirectDebtView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);
    final uid = context.read<AuthBloc>().uid;

    return PageScaffold(
      title: 'Redirect Debt',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? MediaQuery.of(context).size.width / 3 : 30,
        ),
        child: GroupBuilder(
          builder: (context, group) {
            final debtRedirectionCubit = DebtRedirectionCubit(
              uid: uid,
              group: group,
            );
            return BlocProvider.value(
              value: debtRedirectionCubit,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RedirectDebtHeaderText(),
                  RedirectDebtVisual(),
                  RedirectDebtVisual(isAfter: true),
                  SizedBox(height: 50),
                  RedirectDebtCommitButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
