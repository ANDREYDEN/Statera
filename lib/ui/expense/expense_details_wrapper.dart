import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expense/impersonation_cubit.dart';
import 'package:statera/ui/expense/expense_details.dart';

class ExpenseDetailsWrapper extends StatelessWidget {
  const ExpenseDetailsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseState = context.watch<ExpenseBloc>().state;
    final expenseId = expenseState is ExpenseLoaded
        ? expenseState.expense.id
        : null;

    return BlocProvider<ImpersonationCubit>(
      key: ValueKey(expenseId),
      create: (_) => ImpersonationCubit(),
      child: const ExpenseDetails(),
    );
  }
}
