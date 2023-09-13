import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/expenses/expense_list_item/expense_title.dart';
import 'package:statera/ui/group/expenses/expense_list_item/finalize_button.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/helpers.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();
    final isWide = context.read<LayoutState>().isWide;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.all(5),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                expense.getColor(authBloc.uid),
                Theme.of(context).colorScheme.surface,
              ],
              stops: [0, 0.8],
            ),
          ),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () => isWide
                ? expenseBloc.load(expense.id)
                : Navigator.of(context)
                    .pushNamed(ExpensePage.route + '/${expense.id}'),
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
                            GroupBuilder(builder: (context, group) {
                              return UserAvatar(
                                author: group.getMember(expense.authorUid),
                              );
                            }),
                            SizedBox(width: 15),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                      child: ExpenseTitle(expense: expense)),
                                  Text(
                                    pluralize(
                                            'item', this.expense.items.length) +
                                        (toStringDate(this.expense.date) == null
                                            ? ''
                                            : ' on ${toStringDate(this.expense.date)!}'),
                                    style: TextStyle(color: Colors.black),
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
                          PriceText(
                            value: this
                                .expense
                                .getConfirmedTotalForUser(authBloc.uid),
                            textStyle: TextStyle(fontSize: 24),
                          ),
                          PriceText(
                            value: this.expense.total,
                            textStyle: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (expense.canBeFinalizedBy(authBloc.uid)) ...[
                    SizedBox(height: 5),
                    FinalizeButton(expense: expense)
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
