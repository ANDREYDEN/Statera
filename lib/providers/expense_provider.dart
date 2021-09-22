import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';

class ExpenseProvider extends StatelessWidget {
  final Expense expense;
  final Widget child;

  const ExpenseProvider({
    Key? key,
    required this.expense,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<Expense>(
      create: (context) => this.expense,
      builder: (context, _) => this.child,
    );
  }
}
