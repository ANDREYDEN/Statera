import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/custom_filter_chip.dart';
import 'package:statera/widgets/custom_stream_builder.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/listItems/expense_list_item.dart';
import 'package:statera/widgets/ok_cancel_dialog.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  var newExpenseNameController = TextEditingController();
  List<String> _filters = [
    "Not Marked",
    "Pending",
    "Completed"
  ];

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: CustomFilterChip(
                label: "Not Marked",
                color: Colors.red[200]!,
                filtersList: _filters,
                onSelected: (selected) => setState(() => {}),
              ),
            ),
            Flexible(
              child: CustomFilterChip(
                label: "Pending",
                color: Colors.yellow[200]!,
                filtersList: _filters,
                onSelected: (selected) => setState(() => {}),
              ),
            ),
            Flexible(
              child: CustomFilterChip(
                label: "Completed",
                color: Colors.grey[400]!,
                filtersList: _filters,
                onSelected: (selected) => setState(() => {}),
              ),
            ),
          ],
        ),
        Expanded(child: buildExpensesList()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: handleNewExpense,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void handleNewExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          children: [
            TextField(
              controller: newExpenseNameController,
              decoration: InputDecoration(labelText: "Expense name"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              var newExpense = Expense(
                author: Author.fromUser(this.authVm.user),
                name: newExpenseNameController.text,
                groupId: groupVm.group.id,
              );
              await Firestore.instance.addExpenseToGroup(
                newExpense,
                groupVm.group.code,
              );
              newExpenseNameController.clear();
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  Widget buildExpensesList() {
    return CustomStreamBuilder<List<Expense>>(
        stream: Firestore.instance
            .listenForRelatedExpenses(authVm.user.uid, groupVm.group.id),
        builder: (context, expenses) {
          expenses.sort((firstExpense, secondExpense) {
            if (!firstExpense.isMarkedBy(authVm.user.uid)) return -1;
            if (!secondExpense.isMarkedBy(authVm.user.uid)) return 1;

            if (firstExpense.completed) return -1;
            if (secondExpense.completed) return 1;

            return 0;
          });

          expenses = expenses.where((expense) {
            if (_filters.contains("Not Marked") &&
                !expense.isMarkedBy(authVm.user.uid)) {
              return true;
            }

            if (_filters.contains("Pending") &&
                expense.isMarkedBy(authVm.user.uid) &&
                !expense.completed) {
              return true;
            }

            if (_filters.contains("Completed") && expense.completed) {
              return true;
            }

            return false;
          }).toList();

          return expenses.isEmpty
              ? Text("No expenses yet...")
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];

                    return expense.isAuthoredBy(authVm.user.uid) &&
                            !expense.completed
                        ? Dismissible(
                            key: Key(expense.id!),
                            confirmDismiss: (dir) => showDialog<bool>(
                              context: context,
                              builder: (context) => OKCancelDialog(
                                  text:
                                      "Are you sure you want to delete this expense and all of its items?"),
                            ),
                            onDismissed: (_) {
                              Firestore.instance.deleteExpense(expense);
                            },
                            direction: DismissDirection.startToEnd,
                            background: DismissBackground(),
                            child: ExpenseListItem(expense: expense),
                          )
                        : ExpenseListItem(expense: expense);
                  },
                );
        });
  }
}
