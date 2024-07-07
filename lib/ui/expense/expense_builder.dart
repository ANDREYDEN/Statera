import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class ExpenseBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Expense) builder;
  final Widget Function(BuildContext, ExpenseError)? errorBuilder;
  final Widget? loadingWidget;

  const ExpenseBuilder({
    Key? key,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseError) {
          showErrorSnackBar(context, 'Error occured: ${state.error}');
        }
      },
      listenWhen: (previous, current) {
        return current is ExpenseError;
      },
      builder: (expenseContext, state) {
        if (state is ExpenseLoading) {
          return loadingWidget ?? Center(child: Loader());
        }

        if (state is ExpenseError) {
          return errorBuilder == null
              ? Center(child: Text(state.error.toString()))
              : errorBuilder!(expenseContext, state);
        }

        if (state is ExpenseLoaded) {
          return builder(expenseContext, state.expense);
        }

        return Container();
      },
    );
  }
}
