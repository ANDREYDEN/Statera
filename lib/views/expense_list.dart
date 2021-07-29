import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/custom_filter_chip.dart';
import 'package:statera/widgets/crud_dialog.dart';
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
  List<String> _filters = [
    "Not Marked",
    "Pending",
    "Completed"
  ];
  var expenseNameController = TextEditingController();

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
            onPressed: handleCreateExpense,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
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

                    return Dismissible(
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
                            direction: expense.isAuthoredBy(authVm.user.uid) &&
                            !expense.completed
                        ? DismissDirection.startToEnd
                        : DismissDirection.none,
                    background: DismissBackground(),
                    child: GestureDetector(
                      onLongPress: () => handleEditExpense(expense),
                      child: ExpenseListItem(expense: expense),
                    ),);
                  },
                );
        });
  }
  
  void handleCreateExpense() async {
    await showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        label: "Expense Name",
        controller: expenseNameController,
        action: () async {
          var newExpense = Expense(
            author: Author.fromUser(this.authVm.user),
            name: expenseNameController.text,
            groupId: groupVm.group.id,
          );
          await Firestore.instance.addExpenseToGroup(
            newExpense,
            groupVm.group.code,
          );
        },
      ),
    );
    expenseNameController.clear();
  }

  handleEditExpense(Expense expense) async {
    expenseNameController.text = expense.name;
    await showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Expense",
        label: "Expense name",
        controller: expenseNameController,
        action: () async {
          expense.name = expenseNameController.text;
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );

    expenseNameController.clear();
  }
}
