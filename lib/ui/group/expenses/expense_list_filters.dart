import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/ui/group/expenses/expenses_builder.dart';
import 'package:statera/ui/widgets/custom_filter_chip.dart';

class ExpenseListFilters extends StatelessWidget {
  const ExpenseListFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var expensesCubit = context.read<ExpensesCubit>();

    return ExpensesBuilder(
      renderExpensesProcessing: false,
      builder: (context, expensesState) {
        return Row(
          children: ExpenseStage.values
              .map((stage) => Flexible(
                    child: CustomFilterChip(
                      label: stage.name.replaceAll('_', ' '),
                      color: stage.color,
                      selected: expensesState.stages.contains(stage),
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
