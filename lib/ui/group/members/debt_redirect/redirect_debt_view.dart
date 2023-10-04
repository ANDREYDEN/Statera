import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/debt_redirection/debt_redirection_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_fab.dart';
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
    final GroupCubit groupCubit = context.read<GroupCubit>();

    return BlocProvider.value(
      value: DebtRedirectionCubit()
        ..init(
          uid: uid,
          groupCubit: groupCubit,
        ),
      child: PageScaffold(
        title: 'Redirect Debt',
        fab: RedirectDebtFAB(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? MediaQuery.of(context).size.width / 3 : 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RedirectDebtHeaderText(),
              RedirectDebtVisual(),
              RedirectDebtVisual(isAfter: true),
            ],
          ),
        ),
      ),
    );
  }
}
