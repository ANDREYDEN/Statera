import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/assignee_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/dialogs/expense_settings_dialog.dart';
import 'package:statera/ui/widgets/items_list.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/utils/utils.dart';

class ExpensePage extends StatelessWidget {
  static const String route = "/expense";

  final String? expenseId;
  const ExpensePage({Key? key, required this.expenseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (expenseContext, state) {
        if (state is ExpenseLoaded && state.updateFailure != null) {
          showSnackBar(
            expenseContext,
            state.updateFailure == ExpenseUpdateFailure.ExpenseFinalized
                ? 'Expense is finalized and can no longer be edited'
                : "You do'nt have access to edit this expense",
          );
        }
      },
      listenWhen: (before, after) =>
          before is ExpenseLoaded && after is ExpenseLoaded,
      builder: (context, expenseState) {
        if (authBloc.state.status == AuthStatus.unauthenticated) {
          return PageScaffold(child: Text('Unauthorized'));
        }

        if (expenseState is ExpenseLoading) {
          return PageScaffold(
            child: Center(child: Loader()),
          );
        }

        if (expenseState is ExpenseError) {
          return PageScaffold(
            child: Center(child: Text(expenseState.error.toString())),
          );
        }

        if (expenseState is ExpenseLoaded) {
          final expense = expenseState.expense;

          return PageScaffold(
            onFabPressed: expense.canBeUpdatedBy(authBloc.state.user!.uid)
                ? () => _handleCreateItem(context, expenseBloc, authBloc)
                : null,
            actions: [
              if (expense.canBeUpdatedBy(authBloc.state.user!.uid))
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () =>
                      _handleSettingsClick(context, expenseBloc, authBloc),
                )
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ExpenseStages(expense: expense),
                Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          authBloc.getExpenseColor(expense),
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
                                onPressed: () => _handleUpdateDate(
                                  context,
                                  expenseBloc,
                                  authBloc,
                                ),
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
                                onTap: () => _handleUpdateAuthor(
                                  context,
                                  expenseBloc,
                                  authBloc,
                                ),
                              ),
                              Icon(Icons.arrow_forward),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _handleUpdateAssignees(
                                    context,
                                    expenseBloc,
                                    authBloc,
                                  ),
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
                if (expense.hasNoItems)
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ReceiptScanDialog(expense: expense),
                    ),
                    label: Text('Upload receipt'),
                    icon: Icon(Icons.photo_camera),
                  ),
                Flexible(
                  child: expense.hasNoItems
                      ? ListEmpty(text: 'Add items to this expense')
                      : ItemsList(),
                ),
              ],
            ),
          );
        }

        return PageScaffold(child: Container());
      },
    );
  }

  _handleSettingsClick(
    BuildContext context,
    ExpenseBloc expenseBloc,
    AuthBloc authBloc,
  ) {
    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.state.user!,
        update: (expense) async {
          await showDialog(
            context: context,
            builder: (_) => ExpenseSettingsDialog(expense: expense),
          );
        },
      ),
    );
  }

  _handleUpdateDate(
    BuildContext context,
    ExpenseBloc expenseBloc,
    AuthBloc authBloc,
  ) {
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

  _handleUpdateAuthor(
    BuildContext context,
    ExpenseBloc expenseBloc,
    AuthBloc authBloc,
  ) {
    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.state.user!,
        update: (expense) async {
          Author? newAuthor = await showDialog<Author>(
            context: context,
            builder: (_) => AuthorChangeDialog(expense: expense),
          );
          if (newAuthor == null) return;

          expense.author = newAuthor;
        },
      ),
    );
  }

  _handleUpdateAssignees(
    BuildContext context,
    ExpenseBloc expenseBloc,
    AuthBloc authBloc,
  ) async {
    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.state.user!,
        update: (expense) async {
          final newAssignees = await showDialog<List<Assignee>>(
            context: context,
            builder: (context) => AssigneePickerDialog(expense: expense),
          );
          if (newAssignees == null) return;

          expense.assignees = newAssignees;
        },
      ),
    );
  }

  _handleCreateItem(
    BuildContext context,
    ExpenseBloc expenseBloc,
    AuthBloc authBloc,
  ) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Item",
        fields: [
          FieldData(
            id: "item_name",
            label: "Item Name",
            validators: [FieldData.requiredValidator],
          ),
          FieldData(
            id: "item_value",
            label: "Item Value",
            inputType: TextInputType.numberWithOptions(decimal: true),
            validators: [
              FieldData.requiredValidator,
              FieldData.doubleValidator
            ],
            formatters: [CommaReplacerTextInputFormatter()],
          ),
          FieldData(
            id: "item_partition",
            label: "Item Parts",
            inputType: TextInputType.number,
            initialData: 1,
            validators: [FieldData.requiredValidator, FieldData.intValidator],
            formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
          ),
        ],
        onSubmit: (values) {
          expenseBloc.add(
            UpdateRequested(
              issuer: authBloc.state.user!,
              update: (expense) {
                expense.addItem(Item(
                  name: values["item_name"]!,
                  value: double.parse(values["item_value"]!),
                  partition: int.parse(values["item_partition"]!),
                ));
              },
            ),
          );
        },
        allowAddAnother: true,
      ),
    );
  }
}
