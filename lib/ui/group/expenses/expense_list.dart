import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statera/ui/group/expenses/expense_list_filters.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/group/expenses/expenses_list_body.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        ExpenseListFilters(),
        Expanded(
          child: ExpensesBuilder(
            builder: (context, expenses) =>
                ExpensesListBody(expenses: expenses),
          ),
        ),
      ],
    );
  }
}
