part of 'expense_action.dart';

class FinalizeExpenseAction extends ExpenseAction {
  FinalizeExpenseAction(super.expense);

  @override
  IconData get icon => Icons.done;

  @override
  String get name => 'Finalize';

  @override
  handle(BuildContext context) async {
    final valid = await verifyAllItemsValid(context);
    if (!valid) return;

    snackbarCatch(
      context,
      () async {
        final groupCubit = context.read<GroupCubit>();
        final expenseService = context.read<ExpenseService>();

        // TODO: use transaction
        var group = groupCubit.loadedState.group;

        await expenseService.finalizeExpense(expense);
        final payments = await createPayments(context, group);
        updateGroup(groupCubit, payments);
      },
      successMessage:
          "The expense is now finalized. Participants' balances updated.",
    );
  }

  Future<bool> verifyAllItemsValid(BuildContext context) async {
    bool accepted = true;
    if (expense.hasItemsDeniedByAll) {
      accepted = await showDialog<bool>(
            context: context,
            builder: (context) => OKCancelDialog(
              title: 'Some items require attention',
              text:
                  'This expense contains items that were not marked by any of the assignees. This means that you will not be reimbursed for these items from anyone in the group. Are you sure you still want to finalize the expense?',
            ),
          ) ??
          false;
    }

    return accepted;
  }

  /// Add expense payments from author to all assignees
  Future<List<Payment>> createPayments(
      BuildContext context, Group group) async {
    final paymentService = context.read<PaymentService>();

    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
      (assigneeUid) {
        return Payment.fromFinalizedExpense(
          expense: expense,
          receiverId: assigneeUid,
          oldAuthorBalance: group.balance[expense.authorUid]?[assigneeUid],
        );
      },
    );
    await Future.wait(payments.map(paymentService.addPayment));
    return payments.toList();
  }

  void updateGroup(GroupCubit groupCubit, List<Payment> payments) {
    groupCubit.update((group) {
      for (var payment in payments) {
        group.payOffBalance(payment: payment);
      }
    });
  }
}