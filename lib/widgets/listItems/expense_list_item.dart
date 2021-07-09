import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_page.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  Color? getCardColor(String uid) {
    if (this.expense.author.uid == uid) {
      if (this.expense.isPaidFor) return Colors.grey[400];
    }
    if (this.expense.paidBy(uid)) return Colors.grey[400];
    if (this.expense.isReadyToBePaidFor) return Colors.green[200];
    if (!this.expense.isMarkedBy(uid)) return Colors.red[200];
    return Colors.yellow[300];
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
                      Text(
                        this.expense.name,
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("${this.expense.items.length} item(s)"),
                      Text("Payer: ${this.expense.author.name}"),
                      Row(
                        children: [
                          Text("Marked: "),
                          Icon(Icons.person),
                          Text(
                            "${this.expense.definedAssignees}/${this.expense.assignees.length}",
                          )
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        toStringPrice(this
                            .expense
                            .getConfirmedTotalForUser(authVm.user.uid)),
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        toStringPrice(this.expense.total),
                        style: TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text("Paid: "),
                          Icon(Icons.person),
                          Text(
                            "${this.expense.paidAssignees}/${this.expense.assignees.length - 1}",
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
