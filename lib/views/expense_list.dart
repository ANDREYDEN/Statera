import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/listItems/expense_list_item.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  var newExpenseNameController = TextEditingController();

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
    return StreamBuilder<List<Expense>>(
        stream: Firestore.instance
            .listenForRelatedExpenses(authVm.user.uid, groupVm.group.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return Text("Loading...");
          }

          var expenses = snapshot.data!;

          expenses.sort((firstExpense, secondExpense) {
            if (!firstExpense.isMarkedBy(authVm.user.uid)) return -1;
            if (!secondExpense.isMarkedBy(authVm.user.uid)) return 1;

            if (!firstExpense.paidBy(authVm.user.uid)) return -1;
            if (!secondExpense.paidBy(authVm.user.uid)) return 1;

            if (firstExpense.isReadyToBePaidFor) return -1;
            if (secondExpense.isReadyToBePaidFor) return 1;

            return 0;
          });

          return expenses.isEmpty
              ? Text("No expenses yet...")
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];

                    return expense.author.uid == authVm.user.uid
                        ? Dismissible(
                            key: Key(expense.id!),
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
