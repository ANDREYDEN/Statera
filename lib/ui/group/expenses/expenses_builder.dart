import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';

class ExpensesBuilder extends StatelessWidget {
  final Widget Function(BuildContext, List<Expense>, bool) builder;
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
              ? Center(child: SelectableText(state.error.toString()))
              : errorBuilder!(groupContext, state);
        }

        if (state is ExpensesLoaded) {
          return Column(
            children: [
              if (state is ExpensesProcessing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: LinearProgressIndicator(),
                ),
              Expanded(
                child: builder(groupContext, state.expenses, state.allLoaded),
              )
            ],
          );
        }

        return Container();
      },
    );
  }
}
