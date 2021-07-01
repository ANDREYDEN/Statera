import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_page.dart';

enum ExpenseListItemType { ForAuthor, ForEveryone }

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final ExpenseListItemType type;
  const ExpenseListItem({Key? key, required this.expense, required this.type})
      : super(key: key);

  Color? getCardColor(String uid) {
    if (type == ExpenseListItemType.ForEveryone) {
      if (this.expense.finalized) return Colors.grey[400];

      return this.expense.isCompletedByUser(uid)
          ? Colors.green[200]
          : Colors.red[200];
    }
    if (type == ExpenseListItemType.ForAuthor) {
      return this.expense.completed ? Colors.green[200] : Colors.red[200];
    }
    return Colors.grey;
  }

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
        color: this.getCardColor(authVm.user.uid),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(this.expense.name),
                      Text("${this.expense.items.length} item(s)"),
                      Visibility(
                        visible: this.type == ExpenseListItemType.ForEveryone,
                        child: Text("Payer: ${this.expense.author.name}"),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Total: \$${this.expense.total.toStringAsFixed(2)}"),
                      Visibility(
                        visible: this.type == ExpenseListItemType.ForEveryone,
                        child: Text(
                            "My part: \$${this.expense.getTotalForUser(authVm.user.uid).toStringAsFixed(2)}"),
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: this.type == ExpenseListItemType.ForAuthor &&
                    this.expense.completed,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            this.expense.finalized = true;
                            Firestore.instance.saveExpense(this.expense);
                          },
                          child: Text("Finalize")),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
