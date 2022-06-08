import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/dynamic_link_service.dart';
import 'package:statera/ui/expense/assignee_list.dart';
import 'package:statera/ui/expense/expense_action_handlers.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/items/items_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/buttons/share_button.dart';
import 'package:statera/ui/widgets/dialogs/ok_cancel_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/utils/utils.dart';

import 'dialogs/expense_dialogs.dart';

class ExpenseDetails extends StatelessWidget {
  const ExpenseDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expensesCubit = context.read<ExpensesCubit>();
    final isWide = context.select((LayoutState state) => state.isWide);

    return ExpenseBuilder(
      loadingWidget: ListEmpty(text: 'Pick an expense first'),
      builder: (context, expense) {
        final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ShareButton(
                      data: DynamicLinkService.generateDynamicLink(
                        path: ModalRoute.of(context)!.settings.name,
                      ),
                      webIcon: Icons.share,
                    ),
                    if (expense.canBeUpdatedBy(authBloc.uid)) ...[
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => handleSettingsClick(context),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => OKCancelDialog(
                              text:
                                  'Are you sure you want to delete this expense and all of its items?',
                            ),
                          );
                          if (confirmed == true)
                            expensesCubit.deleteExpense(expense);
                        },
                      ),
                    ]
                  ],
                ),
              ),
            Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
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
                          Icon(Icons.schedule, size: 20),
                          TextButton(
                            onPressed: expenseCanBeUpdated
                                ? () => _handleDateClick(context)
                                : null,
                            child: Text(
                              toStringDate(expense.date) ?? 'Not set',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthorAvatar(
                            author: expense.author,
                            onTap: expenseCanBeUpdated
                                ? () => _handleAuthorClick(context)
                                : null,
                          ),
                          Icon(Icons.arrow_forward),
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
            ),
            if (expense.hasNoItems && expenseCanBeUpdated)
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ReceiptScanDialog(expense: expense),
                ),
                label: Text('Upload receipt'),
                icon: Icon(Icons.photo_camera),
              ),
            Flexible(child: ItemsList()),
          ],
        );
      },
    );
  }

  _handleDateClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.state.user!,
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
        issuer: authBloc.state.user!,
        update: (expense) async {
          Author? newAuthor = await showDialog<Author>(
            context: context,
            builder: (_) => BlocProvider<GroupCubit>.value(
              value: context.read<GroupCubit>(),
              child: AuthorChangeDialog(expense: expense),
            ),
          );
          if (newAuthor == null) return;

          expense.author = newAuthor;
        },
      ),
    );
  }

  _handleAssigneesClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.state.user!,
        update: (expense) async {
          final newAssignees = await showDialog<List<Assignee>>(
            context: context,
            builder: (_) => BlocProvider<GroupCubit>.value(
              value: context.read<GroupCubit>(),
              child: AssigneePickerDialog(expense: expense),
            ),
          );
          if (newAssignees == null) return;

          expense.assignees = newAssignees;
        },
      ),
    );
  }
}
