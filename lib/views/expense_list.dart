import 'package:flutter/material.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/widgets/expense_list_item.dart';

class ExpenseList extends StatefulWidget {
  static const String route = "/expense-list";

  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> expenses = [];

  @override
  void initState() {
    var testExpense = Expense(author: "asd", name: "First Expense");
    testExpense.addItem(Item(name: "Apple", value: 4));
    testExpense.addAssignees([Assignee(uid: "asd")]);
    expenses.add(testExpense);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "My Expenses",
      child: ListView.builder(
        itemCount: this.expenses.length,
        itemBuilder: (context, index) {
          var expense = this.expenses[index];

          return ExpenseListItem(expense: expense);
        },
      ),
    );
  }
}
