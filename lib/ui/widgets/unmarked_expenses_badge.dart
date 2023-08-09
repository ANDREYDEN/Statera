import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expenses/unmarked_expenses_cubit.dart';

class UnmarkedExpensesBadge extends StatelessWidget {
  final Widget child;

  const UnmarkedExpensesBadge({Key? key, required this.child})
      : super(key: key);

  Widget build(BuildContext context) {
    return BlocBuilder<UnmarkedExpensesCubit, int?>(
      bloc: context.read<UnmarkedExpensesCubit>(),
      builder: (context, numberOfExpenses) {
        print('Got unmarked expenses: $numberOfExpenses');
        if (numberOfExpenses == null || numberOfExpenses == 0) return child;

        return Badge.count(count: numberOfExpenses, child: child);
      },
    );
  }
}
