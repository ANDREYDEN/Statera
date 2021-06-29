import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
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

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  @override
  void initState() {
    var testExpense =
        Expense(author: this.authVm.user.uid, name: "First Expense");
    testExpense.addItem(Item(name: "Apple", value: 4));
    testExpense.addAssignees([Assignee(uid: this.authVm.user.uid)]);
    expenses.add(testExpense);
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
            content: TextField(
              controller: newExpenseNameController,
              decoration: InputDecoration(labelText: "Expense name"),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    var newExpense = Expense(
                      author: this.authVm.user.uid,
                      name: newExpenseNameController.text,
                    );
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
            child: buildExpensesList(Firestore.instance
                .listenForAssignedExpensesForUser(authVm.user.uid))),
        Text("Authored by me"),
        Expanded(
            child: buildExpensesList(Firestore.instance
                .listenForAuthoredExpensesForUser(authVm.user.uid))),
      ]),
    );
  }

  Widget buildExpensesList(Stream<List<Expense>> stream) {
    return StreamBuilder<List<Expense>>(
        stream: stream,
        builder: (context, snapshot) {
          print(snapshot);
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

              return ExpenseListItem(expense: expense);
            },
          );
        });
  }
}
