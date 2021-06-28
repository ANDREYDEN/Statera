import 'package:flutter/material.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/widgets/item_list_item.dart';

class ExpensePage extends StatefulWidget {
  static const String route = "/expense";

  final Expense expense;
  const ExpensePage({Key? key, required this.expense}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  get items => widget.expense.items;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: widget.expense.name,
      child: ListView.builder(
        itemCount: this.items.length,
        itemBuilder: (context, index) {
          var item = this.items[index];

          return ItemListItem(
            item: item,
            onConfirm: () {
              setState(() {
                item.setAssigneeDecision("asd", ExpenseDecision.Confirmed);
              });
            },
            onDeny: () {
              setState(() {
                item.setAssigneeDecision("asd", ExpenseDecision.Denied);
              });
            },
          );
        },
      ),
    );
  }
}
