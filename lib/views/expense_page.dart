import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/crud_dialog.dart';
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
            onFabPressed: !loading &&
                    expense.isAuthoredBy(authVm.user.uid) &&
                    !expense.completed
                ? () => handleCreateItem(expense)
                : null,
            child: loading
                ? Text("Loading...")
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var expenseStage in authVm.expenseStages)
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  color: expenseStage.test(expense)
                                      ? expenseStage.color
                                      : null,
                                  child: Center(
                                    child: Text(
                                      expenseStage.name,
                                      // textAlign: TextAlign.center,
                                    ),
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
                                onDecisionTaken: (decision) async {
                                  if (expense.completed) return;

                                  expense.items[index].setAssigneeDecision(
                                    this.authVm.user.uid,
                                    decision,
                                  );
                                  await Firestore.instance
                                      .updateExpense(expense);
                                  if (expense.completed) {
                                    snackbarCatch(
                                      context,
                                      () async {
                                        groupVm.updateBalance(expense);
                                        await Firestore.instance
                                            .saveGroup(groupVm.group);
                                      },
                                      successMessage:
                                          "The expense is now complete. Participants' balances updated.",
                                    );
                                  }
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
      builder: (context) => CRUDDialog(
        title: "New Item",
        fields: [
          FieldData(id: "item_name", label: "Item Name"),
          FieldData(
            id: "item_value",
            label: "Item Value",
            inputType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        onSubmit: (values) async {
          expense.addItem(Item(
            name: values["item_name"]!,
            value: double.parse(values["item_value"]!),
          ));
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );
  }
}
