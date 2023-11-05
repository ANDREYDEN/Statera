part of 'expense_details.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  void _copyExpenseName(BuildContext context, String name) async {
    ClipboardData clipData = ClipboardData(text: name);
    await Clipboard.setData(clipData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expense name copied to clipboard')),
    );
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Card(
                        color: Colors.grey[600],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: PriceText(
                            value: expense.total,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 20, color: Colors.black),
                      TextButton(
                        onPressed: expenseCanBeUpdated
                            ? () => _handleDateClick(context)
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
                    children: [
                      GroupBuilder(builder: (context, group) {
                        return UserAvatar(
                          author: group.getMember(expense.authorUid),
                          onTap: expenseCanBeUpdated
                              ? () => _handleAuthorClick(context)
                              : null,
                        );
                      }),
                      Icon(Icons.arrow_forward, color: Colors.black),
                      Expanded(
                        child: GestureDetector(
                          onTap: expenseCanBeUpdated
                              ? () => _handleAssigneesClick(context)
                              : null,
                          child: AssigneeList(),
                        ),
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

  _handleDateClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuerUid: authBloc.uid,
        update: (expense) async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            lastDate: DateTime.now().add(Duration(days: 30)),
          );
          if (newDate == null) return;

          expense.date = newDate;
        },
      ),
    );
  }

  _handleAuthorClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuerUid: authBloc.uid,
        update: (expense) async {
          final newAuthorUid = await showDialog<String?>(
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

          expense.authorUid = newAuthorUid;
        },
      ),
    );
  }

  _handleAssigneesClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuerUid: authBloc.uid,
        update: (expense) async {
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

          expense.updateAssignees(newAssigneeIds);
        },
      ),
    );
  }
}
