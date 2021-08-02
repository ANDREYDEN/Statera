import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_page.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context);

    Color? cardColor = Colors.blue[200];
    authVm.expenseStages.forEach((stage) {
      if (stage.test(this.expense)) {
        cardColor = stage.color;
      }
    });

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpensePage(expenseId: expense.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cardColor ?? Colors.transparent, width: 2),
          color: Colors.grey[100],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: this.expense.author.photoURL == null
                          ? null
                          : NetworkImage(this.expense.author.photoURL!),
                      child: this.expense.author.photoURL != null
                          ? null
                          : Container(color: Colors.grey),
                    ),
                    SizedBox(width: 15),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              this.expense.name,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Text("${this.expense.items.length} item(s)"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    toStringPrice(
                        this.expense.getConfirmedTotalForUser(authVm.user.uid)),
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    toStringPrice(this.expense.total),
                    style: TextStyle(fontSize: 12),
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
