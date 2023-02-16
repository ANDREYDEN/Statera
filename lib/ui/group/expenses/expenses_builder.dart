import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';

class ExpensesBuilder extends StatelessWidget {
  final Widget Function(BuildContext, List<Expense>) builder;
  final Widget Function(BuildContext, ExpensesError)? errorBuilder;
  final Widget? loadingWidget;

  const ExpensesBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesState>(
      builder: (groupContext, state) {
        if (state is ExpensesLoading) {
          return loadingWidget ?? Center(child: Loader());
        }

        if (state is ExpensesError) {
          return errorBuilder == null
              ? Center(child: Text(state.error.toString()))
              : errorBuilder!(groupContext, state);
        }

        if (state is ExpensesLoaded) {
          return Column(
            children: [
              if (state is ExpensesProcessing)
                SizedBox.square(
                  dimension: 16,
                  child: Loader(),
                ),
              Expanded(child: builder(groupContext, state.filteredExpenses))
            ],
          );
        }

        return Container();
      },
    );
  }
}
