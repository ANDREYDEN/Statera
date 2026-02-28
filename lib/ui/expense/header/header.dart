part of '../expense_details.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  Future<void> _copyExpenseName(BuildContext context, String name) async {
    ClipboardData clipData = ClipboardData(text: name);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Expense name copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return ExpenseBuilder(
      builder: (context, expense) {
        final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  expense.getStage(authBloc.uid).color,
                  Theme.of(context).colorScheme.surface,
                ],
                stops: [0, 0.8],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onLongPress: () =>
                              _copyExpenseName(context, expense.name),
                          onHorizontalDragStart: (_) =>
                              _copyExpenseName(context, expense.name),
                          child: Text(
                            expense.name,
                            softWrap: false,
                            style: TextStyle(color: Colors.black, fontSize: 32),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      ExpensePrice(),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 20, color: Colors.black),
                      TextButton(
                        onPressed: expenseCanBeUpdated
                            ? () => _handleDateClick(context, expense)
                            : null,
                        child: Text(
                          toStringDate(expense.date) ?? 'Not set',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GroupBuilder(
                              builder: (context, group) {
                                return UserAvatar(
                                  author: group.getMember(expense.authorUid),
                                  onTap: expenseCanBeUpdated
                                      ? () =>
                                            _handleAuthorClick(context, expense)
                                      : null,
                                );
                              },
                            ),
                            Icon(Icons.arrow_forward, color: Colors.black),
                            Expanded(
                              child: GestureDetector(
                                onTap: expenseCanBeUpdated
                                    ? () => _handleAssigneesClick(
                                        context,
                                        expense,
                                      )
                                    : null,
                                child: AssigneeList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<ExpenseBloc, ExpenseState>(
                        builder: (context, state) =>
                            state is ExpenseLoaded && state.loading
                            ? SizedBox.square(
                                dimension: 15,
                                child: Loader(width: 2),
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _handleDateClick(BuildContext context, Expense expense) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (newDate == null) return;

    final expenseBloc = context.read<ExpenseBloc>();

    expense.date = newDate;
    expenseBloc.add(UpdateRequested(updatedExpense: expense));
  }

  _handleAuthorClick(BuildContext context, Expense expense) async {
    final newAuthorUid = await showDialog<String>(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: context.read<GroupCubit>(),
        child: MemberSelectDialog(
          title: 'Change author',
          singleSelection: true,
          excludeMe: true,
        ),
      ),
    );

    if (newAuthorUid == null) return;

    final expenseBloc = context.read<ExpenseBloc>();

    expense.authorUid = newAuthorUid;
    expenseBloc.add(UpdateRequested(updatedExpense: expense));
  }

  _handleAssigneesClick(BuildContext context, Expense expense) async {
    final newAssigneeIds = await showDialog<List<String>>(
      context: context,
      builder: (_) => BlocProvider<GroupCubit>.value(
        value: context.read<GroupCubit>(),
        child: MemberSelectDialog(
          title: 'Change Assignees',
          value: expense.assigneeUids,
        ),
      ),
    );
    if (newAssigneeIds == null) return;

    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(updatedExpense: expense..updateAssignees(newAssigneeIds)),
    );
  }
}
