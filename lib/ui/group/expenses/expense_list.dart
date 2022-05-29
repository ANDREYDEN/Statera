import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/ui/group/expenses/expense_list_filters.dart';
import 'package:statera/ui/group/expenses/expenses_list_body.dart';
import 'package:statera/ui/widgets/loader.dart';

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
          child: BlocBuilder<ExpensesCubit, ExpensesState>(
            builder: (context, expensesState) {
              if (expensesState is ExpensesLoading) {
                return Loader();
              }

              if (expensesState is ExpensesError) {
                developer.log(
                  'Failed loading expenses',
                  error: expensesState.error,
                );

                return Center(child: Text(expensesState.error.toString()));
              }

              if (expensesState is ExpensesLoaded) {
                final expenses = expensesState.expenses;
                return Column(
                  children: [
                    SizedBox.square(
                      dimension: 16,
                      child: Visibility(
                        visible: expensesState is ExpensesProcessing,
                        child: Loader(),
                      ),
                    ),
                    Expanded(child: ExpensesListBody(expenses: expenses)),
                  ],
                );
              }

              return Container();
            },
          ),
        ),
      ],
    );
  }
}
