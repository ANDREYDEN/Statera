import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/members/debt_redirect/debt_redirect_explainer_dialog.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_commit_button.dart';
import 'package:statera/ui/group/members/debt_redirect/redirect_debt_visual.dart';
import 'package:statera/ui/widgets/section_title.dart';

class RedirectDebtView extends StatelessWidget {
  final Group group;

  const RedirectDebtView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? MediaQuery.of(context).size.width / 3 : 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          SizedBox(height: 20),
          SectionTitle('Before', alignment: Alignment.centerLeft),
          RedirectDebtVisual(),
          SizedBox(height: 20),
          SectionTitle('After', alignment: Alignment.centerLeft),
          RedirectDebtVisual(isAfter: true),
          SizedBox(height: 50),
          RedirectDebtCommitButton(),
        ],
      ),
    );
  }
}
