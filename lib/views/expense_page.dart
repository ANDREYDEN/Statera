import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee_decision.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/widgets/page_scaffold.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';

class ExpensePage extends StatefulWidget {
  static const String route = "/expense";

  final Expense expense;
  const ExpensePage({Key? key, required this.expense}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  var newItemNameController = new TextEditingController();
  var newItemValueController = new TextEditingController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);
  List<Item> get items => widget.expense.items;

  get isAuthoredByCurrentUser => widget.expense.isAuthoredBy(authVm.user.uid);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: widget.expense.name,
      onFabPressed: this.isAuthoredByCurrentUser
          // onFabPressed: true
          ? () {
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
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.expense.addItem(Item(
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
          : null,
      actions: widget.expense.isPaidFor
          ? null
          : [
              ElevatedButton(
                onPressed: () async {
                  await Firestore.instance.saveExpense(widget.expense);
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              ),
            ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: !widget.expense.isMarkedBy(authVm.user.uid)
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
                    color: widget.expense.isMarkedBy(authVm.user.uid) &&
                            !widget.expense.isReadyToBePaidFor &&
                            !widget.expense.isPaidFor
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
                    color: widget.expense.isReadyToBePaidFor &&
                            !widget.expense.isPaidBy(authVm.user.uid)
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
                    color: widget.expense.isPaidBy(authVm.user.uid)
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
                Text("Payer: ${widget.expense.author.name}"),
                Row(
                  children: [
                    Text("Marked: "),
                    Icon(Icons.person),
                    Text(
                      "${widget.expense.definedAssignees}/${widget.expense.assignees.length}",
                    )
                  ],
                ),
                Row(
                  children: [
                    Text("Paid: "),
                    Icon(Icons.person),
                    Text(
                      "${widget.expense.paidAssignees}/${widget.expense.assignees.length - 1}",
                    )
                  ],
                )
              ],
            ),
          ),
          Divider(thickness: 1),
          Flexible(
            child: ListView.builder(
              itemCount: this.items.length,
              itemBuilder: (context, index) {
                var item = this.items[index];

                // TODO: make this conditionally dismissable if finalized
                return Dismissible(
                  key: Key(item.hashCode.toString()),
                  onDismissed: (_) {
                    setState(() {
                      this.items.removeAt(index);
                    });
                  },
                  direction: DismissDirection.startToEnd,
                  background: DismissBackground(),
                  child: ItemListItem(
                    item: item,
                    onConfirm: () {
                      if (widget.expense.isReadyToBePaidFor) return;

                      setState(() {
                        item.setAssigneeDecision(
                          this.authVm.user.uid,
                          ProductDecision.Confirmed,
                        );
                      });
                    },
                    onDeny: () {
                      setState(() {
                        if (widget.expense.isReadyToBePaidFor) return;

                        item.setAssigneeDecision(
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
  }
}
