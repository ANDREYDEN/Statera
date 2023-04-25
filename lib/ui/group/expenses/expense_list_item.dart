import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/callables.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/price_text.dart';
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
      child: GestureDetector(
        onTap: () => isWide
            ? expenseBloc.load(expense.id)
            : Navigator.of(context)
                .pushNamed(ExpensePage.route + '/${expense.id}'),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  expense.getColor(authBloc.state.user!.uid),
                  Theme.of(context).cardColor,
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
                                    child: Text(
                                      this.expense.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
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
                            value: this.expense.getConfirmedTotalForUser(
                                authBloc.state.user!.uid),
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
                  if (expense.canBeFinalizedBy(authBloc.uid))
                    ProtectedButton(
                      onPressed: () {
                        snackbarCatch(
                          GroupPage.scaffoldKey.currentContext!,
                          () => _handleFinalizeExpense(context),
                          successMessage:
                              "The expense is now finalized. Participants' balances updated.",
                        );
                      },
                      child: Text('Finalize'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFinalizeExpense(BuildContext context) async {
    final groupCubit = context.read<GroupCubit>();
    final expenseService = context.read<ExpenseService>();
    final paymentService = context.read<PaymentService>();

    // TODO: use transaction
    await expenseService.finalizeExpense(expense);
    // add expense payments from author to all assignees
    await Future.wait(
      expense.assigneeUids.map((assigneeUid) => paymentService.addPayment(
            Payment(
              groupId: expense.groupId,
              payerId: expense.authorUid,
              receiverId: assigneeUid,
              value: expense.getConfirmedTotalForUser(assigneeUid),
              relatedExpense: PaymentExpenseInfo.fromExpense(expense),
              oldPayerBalance: groupCubit
                  .loadedState.group.balance[expense.authorUid]?[assigneeUid],
                  newFor: [assigneeUid]
            ),
          )),
    );
    try {
      Callables.notifyWhenExpenseFinalized(expenseId: expense.id);
    } catch (e) {
      log(e.toString());
    }
    groupCubit.update((group) => group.updateBalance(expense));
  }
}
