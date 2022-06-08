import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/expenses/expense_list_filters.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/group/expenses/expenses_list_body.dart';
import 'package:statera/ui/group/expenses/new_expense_handler.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        ExpenseListFilters(),
        if (isWide)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: ElevatedButton(
              onPressed: () => handleNewExpenseClick(context),
              child: Icon(Icons.add),
            ),
          ),
        Expanded(child: ExpensesListBody()),
      ],
    );
  }
}
