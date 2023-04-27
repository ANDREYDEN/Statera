import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/callables.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/utils/utils.dart';

class FinalizeButton extends StatelessWidget {
  final Expense expense;
  const FinalizeButton({Key? key, required this.expense}) : super(key: key);

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
                newFor: [assigneeUid]),
          )),
    );
    try {
      Callables.notifyWhenExpenseFinalized(expenseId: expense.id);
    } catch (e) {
      debugPrint(e.toString());
    }
    groupCubit.update((group) => group.updateBalance(expense));
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedButton(
      onPressed: () async {
        bool accepted = true;
        if (expense.hasItemsDeniedByAll) {
          accepted = await showDialog<bool>(
                context: context,
                builder: (context) => OKCancelDialog(
                  text:
                      'This expense contains items that were not marked by any of the assignees. This means that you will not be reimbursed for these items from anyone in the group. Are you sure you still want to finalize the expense?',
                ),
              ) ??
              false;
        }

        if (!accepted) return;

        snackbarCatch(
          GroupPage.scaffoldKey.currentContext!,
          () => _handleFinalizeExpense(context),
          successMessage:
              "The expense is now finalized. Participants' balances updated.",
        );
      },
      child: Text('Finalize'),
    );
  }
}
