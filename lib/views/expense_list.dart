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
  List<Expense> expenses = [];
  var newExpenseNameController = TextEditingController();
  List<Assignee> newExpenseAssignees = [];

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
    return Column(children: [
      Text("Assigned to me"),
      Expanded(
        child: buildExpensesList(
          stream: Firestore.instance
              .listenForAssignedExpenses(authVm.user.uid, groupVm.group.id),
          builder: (expense) => ExpenseListItem(
            expense: expense,
            type: ExpenseListItemType.ForEveryone,
          ),
        ),
      ),
      Text("Authored by me"),
      Expanded(
        child: buildExpensesList(
          stream: Firestore.instance
              .listenForAuthoredExpenses(authVm.user.uid, groupVm.group.id),
          builder: (expense) => Dismissible(
            key: Key(expense.id!),
            onDismissed: (_) {
              Firestore.instance.deleteExpense(expense);
            },
            direction: DismissDirection.startToEnd,
            background: DismissBackground(),
            child: ExpenseListItem(
              expense: expense,
              type: ExpenseListItemType.ForAuthor,
            ),
          ),
        ),
      ),
      Text("Finalized"),
      Expanded(
        child: buildExpensesList(
          stream:
              Firestore.instance.listenForFinalizedExpenses(groupVm.group.id),
          builder: (expense) => ExpenseListItem(
            expense: expense,
            type: ExpenseListItemType.ForEveryone,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(onPressed: handleNewExpense, icon: Icon(Icons.add)),
      ),
    ]);
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
            FutureBuilder<Group>(
              future: Firestore.instance.getGroup(this.groupVm.group.code),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting ||
                    !snap.hasData) {
                  return Text("Loading...");
                }
                var group = snap.data!;

                return MultiSelectDialogField(
                  title: Text('Expense consumers'),
                  buttonText: Text('Expense consumers'),
                  items: group.members
                      .map((member) =>
                          MultiSelectItem<Author?>(member, member.name))
                      .toList(),
                  onConfirm: (List<Author?> selectedMembers) {
                    setState(() {
                      newExpenseAssignees = selectedMembers
                          .map((member) => Assignee(uid: member!.uid))
                          .toList();
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                var newExpense = Expense(
                  author: Author.fromUser(this.authVm.user),
                  name: newExpenseNameController.text,
                  groupId: groupVm.group.id,
                );
                newExpense.addAssignees(newExpenseAssignees);
                this.expenses.add(newExpense);
                Firestore.instance.addExpense(newExpense);
              });
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  Widget buildExpensesList({
    required Stream<List<Expense>> stream,
    required Widget Function(Expense) builder,
  }) {
    return StreamBuilder<List<Expense>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return Text("Loading...");
          }

          var expenses = snapshot.data!;

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              var expense = expenses[index];

              return builder(expense);
            },
          );
        });
  }
}
