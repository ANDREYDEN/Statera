import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/utils/theme.dart';
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

    Color cardBorderColor = Colors.blue[200]!;

    try {
      authVm.expenseStages.forEach((stage) {
        if (this.expense.isIn(stage)) {
          cardBorderColor = stage.color;
        }
      });
    } catch (e) {
      return Text(e.toString());
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ExpensePage.route + '/${expense.id}');
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          gradient: LinearGradient(
            colors: [
              cardBorderColor,
              Theme.of(context).colorScheme.surface,
            ],
            stops: [0, 0.8],
          ),
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
