import 'package:flutter/material.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/page_scaffold.dart';

class ExpenseList extends StatefulWidget {
  static const String route = "/expense-list";

  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> expenses = [Expense(author: "asd", name: "First Expense")];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "My Expenses",
      child: ListView.builder(
        itemCount: this.expenses.length,
        itemBuilder: (context, index) {
          var expense = this.expenses[index];

          return Text(expense.name);
        },
      ),
    );
  }
}
