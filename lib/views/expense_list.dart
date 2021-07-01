import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/Author.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/dismissBackground.dart';
import 'package:statera/widgets/expense_list_item.dart';

class ExpenseList extends StatefulWidget {
  static const String route = "/expense-list";

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "My Expenses",
      onFabPressed: () {
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
                FutureBuilder<List<Author>>(
                  future: Firestore.instance.getUsersGroupMembers(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting ||
                        !snap.hasData) {
                      return Text("Loading...");
                    }
                    var members = snap.data!;

                    return MultiSelectDialogField(
                      title: Text('Expense consumers'),
                      buttonText: Text('Expense consumers'),
                      items: members
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
      },
      child: Column(children: [
        Text("Assigned to me"),
        Expanded(
          child: buildExpensesList(
            stream: Firestore.instance
                .listenForAssignedExpensesForUser(authVm.user.uid),
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
                .listenForAuthoredExpensesForUser(authVm.user.uid),
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
            stream: Firestore.instance
                .listenForFinalizedExpensesForUser(authVm.user.uid),
            builder: (expense) => ExpenseListItem(
              expense: expense,
              type: ExpenseListItemType.ForEveryone,
            ),
          ),
        ),
      ]),
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
