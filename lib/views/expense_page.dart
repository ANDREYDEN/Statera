import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';
import 'package:statera/widgets/page_scaffold.dart';

class ExpensePage extends StatefulWidget {
  static const String route = "/expense";

  final String? expenseId;
  const ExpensePage({Key? key, required this.expenseId}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  var newItemNameController = new TextEditingController();
  var newItemValueController = new TextEditingController();
  var valueFocusNode = new FocusNode();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Expense>(
        stream: Firestore.instance.listenForExpense(widget.expenseId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Text("Error: ${snap.error}");
          }

          bool loading = (!snap.hasData ||
              snap.connectionState == ConnectionState.waiting);

          Expense expense = loading ? Expense.fake() : snap.data!;

          return PageScaffold(
            title: loading ? 'Loading...' : expense.name,
            onFabPressed: !loading && expense.isAuthoredBy(authVm.user.uid) && !expense.completed
                ? () => handleCreateItem(expense)
                : null,
            child: loading
                ? Text("Loading...")
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: !expense.isMarkedBy(authVm.user.uid)
                                    ? Colors.red[200]
                                    : null,
                                child: Text(
                                  'Requires marking',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: expense.isMarkedBy(authVm.user.uid) &&
                                        !expense.completed
                                    ? Colors.yellow[300]
                                    : null,
                                child: Text(
                                  'Marked',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: expense.completed
                                    ? Colors.grey[400]
                                    : null,
                                child: Text(
                                  'Completed',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Payer: ${expense.author.name}"),
                            Row(
                              children: [
                                Text("Marked: "),
                                Icon(Icons.person),
                                Text(
                                  "${expense.definedAssignees}/${expense.assignees.length}",
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(thickness: 1),
                      Flexible(
                        child: ListView.builder(
                          itemCount: expense.items.length,
                          itemBuilder: (context, index) {
                            var item = expense.items[index];

                            // TODO: make this conditionally dismissable if finalized
                            return Dismissible(
                              key: Key(item.hashCode.toString()),
                              onDismissed: (_) async {
                                if (expense.completed) return;

                                expense.items.removeAt(index);
                                await Firestore.instance.updateExpense(expense);
                              },
                              direction: DismissDirection.startToEnd,
                              background: DismissBackground(),
                              child: ItemListItem(
                                item: item,
                                onConfirm: () async {
                                  if (expense.completed) return;

                                  expense.items[index].setAssigneeDecision(
                                    this.authVm.user.uid,
                                    ProductDecision.Confirmed,
                                  );
                                  await Firestore.instance
                                      .updateExpense(expense);
                                  if (expense.completed) {
                                    snackbarCatch(
                                      context,
                                      () async {
                                        groupVm.updateBalance(expense);
                                        await Firestore.instance.saveGroup(groupVm.group);
                                      },
                                      successMessage:
                                          "The expense is now complete. Participants' balances updated.",
                                    );
                                  }
                                },
                                onDeny: () async {
                                  if (expense.completed) return;

                                  expense.items[index].setAssigneeDecision(
                                    this.authVm.user.uid,
                                    ProductDecision.Denied,
                                  );
                                  await Firestore.instance
                                      .updateExpense(expense);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        });
  }

  handleCreateItem(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newItemNameController,
              decoration: InputDecoration(labelText: "Item name"),
              autofocus: true,
              onSubmitted: (text) {
                FocusScope.of(context).requestFocus(this.valueFocusNode);
              },
            ),
            TextField(
              controller: newItemValueController,
              decoration: InputDecoration(labelText: "Item value"),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              focusNode: this.valueFocusNode,
              onSubmitted: (text) {
                submitItem(context, expense);
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => submitItem(context, expense),
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  submitItem(BuildContext context, Expense expense) async {
    expense.addItem(Item(
      name: newItemNameController.text,
      value: double.parse(newItemValueController.text),
    ));
    await Firestore.instance.updateExpense(expense);
    newItemNameController.clear();
    newItemValueController.clear();
    Navigator.of(context).pop();
  }
}
