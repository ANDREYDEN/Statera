import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/assignee.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/page_scaffold.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/item_list_item.dart';

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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: widget.expense.name,
      onFabPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("New Expense"),
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
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              )
            ],
          ),
        );
      },
      actions: [
        ElevatedButton(
          onPressed: () async {
            await Firestore.instance.saveExpense(widget.expense);
            Navigator.of(context).pop();
          },
          child: Text("Save"),
        ),
      ],
      child: ListView.builder(
        itemCount: this.items.length,
        itemBuilder: (context, index) {
          var item = this.items[index];

          return ItemListItem(
            item: item,
            onConfirm: () {
              setState(() {
                item.setAssigneeDecision(
                    this.authVm.user.uid, ExpenseDecision.Confirmed);
              });
            },
            onDeny: () {
              setState(() {
                item.setAssigneeDecision(
                    this.authVm.user.uid, ExpenseDecision.Denied);
              });
            },
          );
        },
      ),
    );
  }
}
