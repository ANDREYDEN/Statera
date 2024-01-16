part of 'expense_action.dart';

class RevertExpenseAction extends ExpenseAction {
  RevertExpenseAction(super.expense);

  @override
  IconData get icon => Icons.undo;

  @override
  String get name => 'Revert';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  @protected
  handle(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Revert expense',
        text:
            'Are you sure you want to revert this expense? All members that took part in this expense will be refunded and the expense will become active again.',
      ),
    );

    if (confirmed == false) return;

    final groupCubit = context.read<GroupCubit>();
    final expensesCubit = context.readOrDefault<ExpensesCubit>();
    final expenseService = context.read<ExpenseService>();
    final paymentService = context.read<PaymentService>();

    // TODO: use transaction
    final group = groupCubit.loadedState.group;

    expensesCubit?.process();
    await expenseService.revertExpense(expense);
    // add expense payments from all assignees to author
    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
          (assigneeUid) => Payment.fromRevertedExpense(
            expense: expense,
            payerId: assigneeUid,
            oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
          ),
        );
    await Future.wait(payments.map(paymentService.addPayment));

    groupCubit.update((group) {
      for (var payment in payments) {
        group.payOffBalance(payment: payment);
      }
    });
  }
}
