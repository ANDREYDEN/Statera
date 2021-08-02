import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/custom_filter_chip.dart';
import 'package:statera/widgets/crud_dialog.dart';
import 'package:statera/widgets/custom_stream_builder.dart';
import 'package:statera/widgets/dismiss_background.dart';
import 'package:statera/widgets/listItems/expense_list_item.dart';
import 'package:statera/widgets/ok_cancel_dialog.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<String> _filters = [];
  var expenseNameController = TextEditingController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  void initState() {
    _filters = authVm.expenseStages.map((stage) => stage.name).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var stage in authVm.expenseStages)
              Flexible(
                child: CustomFilterChip(
                  label: stage.name,
                  color: stage.color,
                  filtersList: _filters,
                  onSelected: (selected) => setState(() => {}),
                ),
              )
          ],
        ),
        Expanded(child: buildExpensesList()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: handleCreateExpense,
            onLongPress: handleScan,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildExpensesList() {
    return CustomStreamBuilder<List<Expense>>(
      stream: Firestore.instance
          .listenForRelatedExpenses(authVm.user.uid, groupVm.group.id),
      builder: (context, expenses) {
        expenses.sort((firstExpense, secondExpense) {
          for (var stage in authVm.expenseStages) {
            if (stage.test(firstExpense)) return -1;
            if (stage.test(secondExpense)) return 1;
          }

          return 0;
        });

        expenses = expenses
            .where(
              (expense) => authVm.expenseStages.any(
                (stage) => _filters.contains(stage.name) && stage.test(expense),
              ),
            )
            .toList();

        return expenses.isEmpty
            ? Text("No expenses yet...")
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index];

                  return Dismissible(
                    key: Key(expense.id!),
                    confirmDismiss: (dir) => showDialog<bool>(
                      context: context,
                      builder: (context) => OKCancelDialog(
                          text:
                              "Are you sure you want to delete this expense and all of its items?"),
                    ),
                    onDismissed: (_) {
                      Firestore.instance.deleteExpense(expense);
                    },
                    direction: expense.isAuthoredBy(authVm.user.uid) &&
                            !expense.completed
                        ? DismissDirection.startToEnd
                        : DismissDirection.none,
                    background: DismissBackground(),
                    child: GestureDetector(
                      onLongPress: () => handleEditExpense(expense),
                      child: ExpenseListItem(expense: expense),
                    ),
                  );
                },
              );
      },
    );
  }

  void handleScan() async {
    // TODO: get photo from photo picker
    // TODO: upload photo to storage and get the url
    const url =
        "https://firebasestorage.googleapis.com/v0/b/statera-0.appspot.com/o/receipt.jpg?alt=media%26token=ae9766ca-063d-4aad-a510-d168b9dde125";
    var getItemsFromImage =
        FirebaseFunctions.instance.httpsCallable('getReceiptData');
    var expense = new Expense(
      author: Author.fromUser(this.authVm.user),
      name: "Scanned expense",
      groupId: groupVm.group.id,
    );
    await snackbarCatch(context, () async {
      var response = await getItemsFromImage({
        'receiptUrl': url
      });
      List<dynamic> items = response.data;

      items.forEach((item) {
        expense.addItem(Item.fromFirestore(item));
      });
    });
    await Firestore.instance.addExpenseToGroup(
      expense,
      groupVm.group.code,
    );
  }

  void handleCreateExpense() async {
    await showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense Name",
            controller: expenseNameController,
          )
        ],
        onSubmit: (values) async {
          var newExpense = Expense(
            author: Author.fromUser(this.authVm.user),
            name: values["expense_name"]!,
            groupId: groupVm.group.id,
          );
          await Firestore.instance.addExpenseToGroup(
            newExpense,
            groupVm.group.code,
          );
        },
      ),
    );
    expenseNameController.clear();
  }

  handleEditExpense(Expense expense) async {
    expenseNameController.text = expense.name;
    await showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense name",
            controller: expenseNameController,
          )
        ],
        onSubmit: (values) async {
          expense.name = values["expense_name"]!;
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );

    expenseNameController.clear();
  }
}
