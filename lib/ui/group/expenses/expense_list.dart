import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/services/feature_service.dart';
import 'package:statera/ui/group/expenses/expense_list_filters.dart';
import 'package:statera/ui/group/expenses/expenses_list_body.dart';
import 'package:statera/ui/group/expenses/expenses_list_body_old.dart';
import 'package:statera/ui/group/expenses/new_expense_button.dart';
import 'package:statera/utils/utils.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);
    final featureService = context.read<FeatureService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        Padding(
          padding: isWide ? EdgeInsets.all(0) : kMobileMargin,
          child: ExpenseListFilters(),
        ),
        if (isWide) NewExpenseButton(),
        SizedBox(height: 10),
        Expanded(
          child: featureService.useDynamicExpenseLoading
              ? ExpensesListBody()
              : ExpensesListBodyOld(),
        ),
      ],
    );
  }
}
