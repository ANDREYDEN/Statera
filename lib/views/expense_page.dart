import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/crud_dialog.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';
import 'package:statera/widgets/list_empty.dart';
import 'package:statera/widgets/optionally_dismissible.dart';
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

        bool loading =
            (!snap.hasData || snap.connectionState == ConnectionState.waiting);

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
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      for (var expenseStage in authVm.expenseStages)
                        Expanded(
                          child: Opacity(
                            opacity: expenseStage.test(expense) ? 1 : 0.7,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: expenseStage.color,
                                  width: 2,
                                ),
                                color: expenseStage.test(expense)
                                    ? expenseStage.color
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  expenseStage.name,
                                  // textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                    child: expense.items.length == 0
                        ? ListEmpty(text: 'Add items to this expense')
                        : ListView.builder(
                            itemCount: expense.items.length,
                            itemBuilder: (context, index) {
                              var item = expense.items[index];

                              // TODO: make this conditionally dismissable if finalized
                              return OptionallyDismissible(
                                key: Key(item.hashCode.toString()),
                                isDismissible:
                                    expense.canBeUpdatedBy(authVm.user.uid),
                                onDismissed: (_) async {
                                  if (expense.completed) return;

                                  expense.items.removeAt(index);
                                  await Firestore.instance
                                      .updateExpense(expense);
                                },
                                child: GestureDetector(
                                  onLongPress: () =>
                                      handleEditItem(expense, item),
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
                                ),
                              );
                            },
                          ),
                  ),
                ]),
        );
      },
    );
  }

  handleCreateItem(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Item",
        fields: [
          FieldData(
            id: "item_name",
            label: "Item Name",
            formatters: [FieldData.requiredFormatter],
          ),
          FieldData(
            id: "item_value",
            label: "Item Value",
            inputType: TextInputType.numberWithOptions(decimal: true),
            formatters: [
              FieldData.requiredFormatter,
              FieldData.numberFormatter
            ],
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

  handleEditItem(Expense expense, Item item) {
    if (!expense.canBeUpdatedBy(authVm.user.uid)) return;

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Item",
        fields: [
          FieldData(
            id: "item_name",
            label: "Item Name",
            initialData: item.name,
            formatters: [FieldData.requiredFormatter],
          ),
          FieldData(
            id: "item_value",
            label: "Item Value",
            initialData: item.value,
            inputType: TextInputType.numberWithOptions(decimal: true),
            formatters: [
              FieldData.requiredFormatter,
              FieldData.numberFormatter
            ],
          ),
        ],
        onSubmit: (values) async {
          item.name = values["item_name"]!;
          item.value = double.parse(values["item_value"]!);
          expense.updateItem(item);
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );
  }
}
