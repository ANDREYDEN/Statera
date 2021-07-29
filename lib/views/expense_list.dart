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
  List<String> _filters = [];

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  void initState() {
    _filters = authVm.expenseStages.map((stage) => stage.name).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var stage in authVm.expenseStages)
              Flexible(
                child: CustomFilterChip(
                  label: stage.name,
                  color: stage.color,
                  filtersList: _filters,
                  onSelected: (selected) => setState(() => {}),
                ),
              )
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
            for (var stage in authVm.expenseStages) {
              if (stage.test(firstExpense)) return -1;
              if (stage.test(secondExpense)) return 1;
            }

            return 0;
          });

          expenses = expenses
              .where(
                (expense) => authVm.expenseStages.any(
                  (stage) =>
                      _filters.contains(stage.name) && stage.test(expense),
                ),
              )
              .toList();

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
