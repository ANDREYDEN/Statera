import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/widgets/custom_filter_chip.dart';

class ExpenseListFilters extends StatelessWidget {
  const ExpenseListFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authBloc = context.read<AuthBloc>();
    var expensesCubit = context.read<ExpensesCubit>();

    return ExpensesBuilder(
      renderExpensesProcessing: false,
      builder: (context, expensesState) {
        final _stageNames = expensesState.stages.map((s) => s.name).toList();

        return Row(
          children: Expense.expenseStages(authBloc.uid)
              .map((stage) => Flexible(
                    child: CustomFilterChip(
                      label: stage.name,
                      color: stage.color,
                      filtersList: _stageNames,
                      onSelected: (selected) {
                        if (selected) {
                          expensesCubit.selectExpenseStages(
                              [...expensesState.stages, stage]);
                        } else {
                          expensesCubit.selectExpenseStages(
                            expensesState.stages
                                .where((s) => s != stage)
                                .toList(),
                          );
                        }
                      },
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
