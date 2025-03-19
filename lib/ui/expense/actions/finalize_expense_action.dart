part of 'expense_action.dart';

class FinalizeExpenseAction extends ExpenseAction {
  FinalizeExpenseAction(super.expense);

  @override
  IconData get icon => Icons.check;

  @override
  String get name => 'Finalize';

  Future handle(BuildContext context) {
    return snackbarCatch(
      context,
      () async {
        final valid = await _verifyAllItemsValid(context, expense);
        if (!valid) return;

        final expensesCubit = context.read<ExpensesCubit>();

        await expensesCubit.finalizeExpense(expense);
      },
      successMessage:
          "The expense is now finalized. Participants' balances updated.",
    );
  }

  Future<bool> _verifyAllItemsValid(
    BuildContext context,
    Expense expense,
  ) async {
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
}
