import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/actions/expense_action.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/expenses/expense_list_item/expense_title.dart';
import 'package:statera/ui/group/expenses/expense_list_item/finalize_button.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/utils/utils.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseBloc = context.watch<ExpenseBloc>();
    final isWide = context.read<LayoutState>().isWide;
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    final isSelected = expenseBloc.state is ExpenseLoaded &&
        (expenseBloc.state as ExpenseLoaded).expense.id == expense.id;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isWide ? 0 : kMobileMargin.left,
      ),
      clipBehavior: Clip.hardEdge,
      shape: isSelected
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withAlpha(150),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            )
          : null,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              expense.getStage(uid).color,
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
          onLongPress: () => EditExpenseAction(expense).handle(context),
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
                                Flexible(child: ExpenseTitle(expense: expense)),
                                Text(
                                  pluralize('item', this.expense.items.length) +
                                      (this.expense.date == null
                                          ? ''
                                          : ' · ${toRelativeStringDate(this.expense.date)!}'),
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
                          value: this.expense.getConfirmedTotalForUser(uid),
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
                if (expense.canBeFinalizedBy(uid)) ...[
                  SizedBox(height: 5),
                  FinalizeButton(expenseId: expense.id)
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
