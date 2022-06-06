import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/buttons/protected_elevated_button.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/utils/helpers.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = context.read<AuthBloc>();
    final groupCubit = context.read<GroupCubit>();
    final expenseBloc = context.read<ExpenseBloc>();
    final isWide = context.read<LayoutState>().isWide;

    return GestureDetector(
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
                                      (toStringDate(this.expense.date) == null
                                          ? ""
                                          : " on ${toStringDate(this.expense.date)!}"),
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
                if (expense.canBeFinalizedBy(authBloc.state.user!.uid))
                  ProtectedElevatedButton(
                    onPressed: () {
                      snackbarCatch(
                        GroupPage.scaffoldKey.currentContext!,
                        () async {
                          // TODO: use transaction
                          await ExpenseService.instance
                              .finalizeExpense(expense);
                          groupCubit.updateBalance(expense);
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
