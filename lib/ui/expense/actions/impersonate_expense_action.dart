part of 'expense_action.dart';

class ImpersonateExpenseAction extends ExpenseAction {
  ImpersonateExpenseAction(super.expense);

  @override
  IconData get icon => Icons.visibility_outlined;

  @override
  String get name => 'View as...';

  @override
  @protected
  Future<void> handle(BuildContext context) async {
    final impersonationCubit = context.read<ImpersonationCubit>();
    final groupCubit = context.read<GroupCubit>();

    final selectedUid = await showDialog<String>(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: groupCubit,
        child: MemberSelectDialog(
          title: 'View expense as',
          singleSelection: true,
          excludeMe: true,
          memberUids: expense.assigneeUids,
        ),
      ),
    );

    if (selectedUid == null) return;

    impersonationCubit.start(selectedUid);
  }
}
