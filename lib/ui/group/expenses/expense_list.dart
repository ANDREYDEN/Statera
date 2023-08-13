import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/expenses/expense_list_filters.dart';
import 'package:statera/ui/group/expenses/expenses_list_body.dart';
import 'package:statera/ui/group/expenses/expenses_list_body_old.dart';
import 'package:statera/ui/group/expenses/new_expense_button.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);
    final useDynamicExpenseLoading = FirebaseRemoteConfig.instance
        .getBool('dynamic_expense_loading_feature_flag');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        ExpenseListFilters(),
        if (isWide) NewExpenseButton(),
        Expanded(
          child: useDynamicExpenseLoading
              ? ExpensesListBody()
              : ExpensesListBodyOld(),
        ),
      ],
    );
  }
}
