import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/custom_filter_chip.dart';

class ExpenseListFilters extends StatefulWidget {
  const ExpenseListFilters({Key? key}) : super(key: key);

  @override
  State<ExpenseListFilters> createState() => _ExpenseListFiltersState();
}

class _ExpenseListFiltersState extends State<ExpenseListFilters> {
  List<ExpenseStage> _selectedStages = [];

  AuthBloc get authBloc => context.read<AuthBloc>();
  ExpensesCubit get expensesCubit => context.read<ExpensesCubit>();
  List<String> get _stageNames => _selectedStages.map((s) => s.name).toList();

  @override
  void initState() {
    super.initState();
    _selectedStages =
        Expense.expenseStages(authBloc.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var stage in Expense.expenseStages(authBloc.uid))
          Flexible(
            child: CustomFilterChip(
              label: stage.name,
              color: stage.color,
              filtersList: _stageNames,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStages.add(stage);
                  } else {
                    _selectedStages.remove(stage);
                  }
                });

                expensesCubit.selectExpenseStages(_selectedStages);
              },
            ),
          )
      ],
    );
  }
}
