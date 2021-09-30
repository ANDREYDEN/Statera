import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/expense_page.dart';
import 'package:statera/widgets/custom_filter_chip.dart';
import 'package:statera/widgets/custom_stream_builder.dart';
import 'package:statera/widgets/dialogs/crud_dialog.dart';
import 'package:statera/widgets/listItems/expense_list_item.dart';
import 'package:statera/widgets/list_empty.dart';
import 'package:statera/widgets/optionally_dismissible.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  late Stream<List<Expense>> _expenseStream;
  List<String> _filters = [];
  final ImagePicker _picker = ImagePicker();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  void initState() {
    _filters = authVm.expenseStages.map((stage) => stage.name).toList();
    _expenseStream = Firestore.instance
        .listenForRelatedExpenses(authVm.user.uid, groupVm.group.id);
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
                  // TODO: this is bad
                  onSelected: (selected) => setState(() => {}),
                ),
              )
          ],
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              buildExpensesList(),
              Positioned(
                bottom: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: handleCreateExpense,
                    onLongPress: kIsWeb
                        ? () {}
                        : handleScan, // TODO: handle picker on web
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                      onPrimary: Theme.of(context).colorScheme.onSecondary,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(18),
                      elevation: 5,
                    ),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildExpensesList() {
    return CustomStreamBuilder<List<Expense>>(
      stream: this._expenseStream,
      builder: (context, expenses) {
        snackbarCatch(context, () {
          expenses.sort((firstExpense, secondExpense) {
            for (var stage in authVm.expenseStages) {
              if (firstExpense.isIn(stage) && secondExpense.isIn(stage)) {
                return firstExpense.wasEarlierThan(secondExpense) ? 1 : -1;
              }
              if (firstExpense.isIn(stage)) return -1;
              if (secondExpense.isIn(stage)) return 1;
            }

            return 0;
          });

          expenses = expenses
              .where(
                (expense) => authVm.expenseStages.any(
                  (stage) =>
                      _filters.contains(stage.name) && expense.isIn(stage),
                ),
              )
              .toList();
        });

        return expenses.isEmpty
            ? ListEmpty(text: "Start by adding an expense")
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index];

                  return OptionallyDismissible(
                    key: Key(expense.id!),
                    isDismissible: expense.isAuthoredBy(authVm.user.uid) &&
                        !expense.completed,
                    confirmation:
                        "Are you sure you want to delete this expense and all of its items?",
                    onDismissed: (_) {
                      Firestore.instance.deleteExpense(expense);
                    },
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null)
      throw new Exception("Something went wrong while taking a photo");

    var task = await FirebaseStorage.instance
        .ref(pickedFile.name)
        .putFile(File(pickedFile.path));

    String url = await task.ref.getDownloadURL();
    var getItemsFromImage =
        FirebaseFunctions.instance.httpsCallable('getReceiptData');

    var expense = new Expense(
      author: Author.fromUser(this.authVm.user),
      name: "Scanned expense",
      groupId: groupVm.group.id,
    );

    var scanSuccessful = await snackbarCatch(
      context,
      () async {
        var response = await getItemsFromImage({'receiptUrl': url});
        List<dynamic> items = response.data;

        items.forEach((itemData) {
          try {
            var item = Item(
              name: itemData["name"] ?? "",
              value: double.tryParse(itemData["value"].toString()) ?? 0,
            );
            expense.addItem(item);
          } catch (e) {
            print("Could not parse item $itemData: $e");
          }
        });
      },
      errorMessage: 'Something went wrong while processing your photo',
    );

    if (scanSuccessful) {
      await Firestore.instance.addExpenseToGroup(
        expense,
        groupVm.group.code,
      );
    }
  }

  void handleCreateExpense() {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense Name",
            validators: [FieldData.requiredValidator],
          )
        ],
        closeAfterSubmit: false,
        onSubmit: (values) async {
          var newExpense = Expense(
            author: Author.fromUser(this.authVm.user),
            name: values["expense_name"]!,
            groupId: groupVm.group.id,
          );
          final expenseId = await Firestore.instance.addExpenseToGroup(
            newExpense,
            groupVm.group.code,
          );
          Navigator.of(context).popAndPushNamed('${ExpensePage.route}/$expenseId');
        },
      ),
    );
  }

  handleEditExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense name",
            validators: [FieldData.requiredValidator],
            initialData: expense.name,
          )
        ],
        onSubmit: (values) async {
          expense.name = values["expense_name"]!;
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );
  }
}
