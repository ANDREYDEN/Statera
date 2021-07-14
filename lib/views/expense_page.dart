import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
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

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

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
            onFabPressed: !loading && expense.isAuthoredBy(authVm.user.uid)
                ? handleCreateItem
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
                                        !expense.isReadyToBePaidFor &&
                                        !expense.isPaidFor
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
                                color: expense.isReadyToBePaidFor &&
                                        !expense.isPaidBy(authVm.user.uid)
                                    ? Colors.green[200]
                                    : null,
                                child: Text(
                                  'Ready to be paid',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: expense.isPaidBy(authVm.user.uid)
                                    ? Colors.grey[400]
                                    : null,
                                child: Text(
                                  'Paid',
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
                            Row(
                              children: [
                                Text("Paid: "),
                                Icon(Icons.person),
                                Text(
                                  "${expense.paidAssignees}/${expense.assignees.length - 1}",
                                )
                              ],
                            )
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
                                if (expense.paymentInProgress) return;

                                await Firestore.instance
                                    .updateExpense(expense.id, (expense) {
                                  expense.items.removeAt(index);
                                });
                              },
                              direction: DismissDirection.startToEnd,
                              background: DismissBackground(),
                              child: ItemListItem(
                                item: item,
                                onConfirm: () async {
                                  if (expense.paymentInProgress) return;
                                  await Firestore.instance
                                      .updateExpense(expense.id, (expense) {
                                    expense.items[index].setAssigneeDecision(
                                      this.authVm.user.uid,
                                      ProductDecision.Confirmed,
                                    );
                                  });
                                },
                                onDeny: () async {
                                  if (expense.paymentInProgress) return;

                                  await Firestore.instance
                                      .updateExpense(expense.id, (expense) {
                                    expense.items[index].setAssigneeDecision(
                                      this.authVm.user.uid,
                                      ProductDecision.Denied,
                                    );
                                  });
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

  handleCreateItem() {
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
            ),
            TextField(
              controller: newItemValueController,
              decoration: InputDecoration(labelText: "Item value"),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await Firestore.instance.updateExpense(widget.expenseId,
                  (expense) {
                expense.addItem(Item(
                  name: newItemNameController.text,
                  value: double.parse(newItemValueController.text),
                ));
              });
              newItemNameController.clear();
              newItemValueController.clear();
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }
}
