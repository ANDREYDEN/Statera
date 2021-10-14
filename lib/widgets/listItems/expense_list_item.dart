import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/views/expense_page.dart';
import 'package:statera/widgets/author_avatar.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ExpensePage.route + '/${expense.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                authVm.getExpenseColor(this.expense),
                Theme.of(context).colorScheme.surface,
              ],
              stops: [0, 0.8],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthorAvatar(author: this.expense.author),
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
                                Text(
                                  pluralize('item', this.expense.items.length) +
                                      (this.expense.formattedDate == null
                                          ? ""
                                          : " on ${this.expense.formattedDate!}"),
                                ),
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
                          toStringPrice(this
                              .expense
                              .getConfirmedTotalForUser(authVm.user.uid)),
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
                if (expense.canBeFinalizedBy(authVm.user.uid))
                  ElevatedButton(
                    onPressed: () {
                      snackbarCatch(
                        context,
                        () async {
                          await Firestore.instance.finalizeExpense(expense);
                          final group = await Firestore.instance
                              .getExpenseGroupStream(expense)
                              .first;
                          group.updateBalance(expense);
                          await Firestore.instance.saveGroup(group);
                        },
                        successMessage:
                            "The expense is now finalized. Participants' balances updated.",
                      );
                    },
                    child: Text("Finalize"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
