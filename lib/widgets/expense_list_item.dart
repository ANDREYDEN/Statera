import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_page.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpensePage(expense: expense),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        color: this.expense.isCompletedForUser(authVm.user.uid)
            ? Colors.green[200]
            : Colors.red[200],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(this.expense.name),
                  Text("${this.expense.items.length} item(s)")
                ],
              ),
              Text("\$${this.expense.total.toStringAsFixed(2)}"),
            ],
          ),
        ),
      ),
    );
  }
}
