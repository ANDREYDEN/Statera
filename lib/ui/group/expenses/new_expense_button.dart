import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class NewExpenseButton extends StatelessWidget {
  const NewExpenseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseBloc = context.read<ExpenseBloc>();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FilledButton(
        onPressed: () => showNewExpenseDialog(
          context,
          afterAddition: expenseBloc.load,
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
