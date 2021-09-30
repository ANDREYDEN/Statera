import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/providers/expense_provider.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/formatters.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/assignee_list.dart';
import 'package:statera/widgets/author_avatar.dart';
import 'package:statera/widgets/dialogs/assignee_picker_dialog.dart';
import 'package:statera/widgets/dialogs/author_change_dialog.dart';
import 'package:statera/widgets/dialogs/crud_dialog.dart';
import 'package:statera/widgets/items_list.dart';
import 'package:statera/widgets/list_empty.dart';
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

  final ImagePicker _picker = ImagePicker();

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

        Expense expense = loading ? Expense.empty() : snap.data!;

        return ExpenseProvider(
          expense: expense,
          child: PageScaffold(
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
                      // ExpenseStages(expense: expense),
                      Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      expense.name,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.grey[700],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        toStringPrice(expense.total),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (!expense.canBeUpdatedBy(authVm.user.uid))
                                    return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => AssigneePickerDialog(
                                      expense: expense,
                                    ),
                                  );
                                },
                                child: AssigneeList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 20),
                                TextButton(
                                  onPressed: () async {
                                    if (!expense.canBeUpdatedBy(
                                        authVm.user.uid)) return;

                                    DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              0),
                                      lastDate: DateTime.now().add(
                                        Duration(days: 30),
                                      ),
                                    );

                                    if (newDate == null) return;

                                    expense.date = newDate;
                                    await Firestore.instance
                                        .updateExpense(expense);
                                  },
                                  child: Text(
                                    expense.formattedDate ?? 'Not set',
                                  ),
                                ),
                              ],
                            ),
                            Text("Payer:"),
                            AuthorAvatar(
                              author: expense.author,
                              onTap: () async {
                                if (!expense.canBeUpdatedBy(authVm.user.uid))
                                  return;

                                Author? newAuthor = await showDialog<Author>(
                                  context: context,
                                  builder: (context) => AuthorChangeDialog(
                                    expense: expense,
                                  ),
                                );

                                if (newAuthor == null) return;

                                expense.author = newAuthor;
                                await Firestore.instance.updateExpense(expense);
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(thickness: 1),
                      if (expense.hasNoItems && !kIsWeb)
                        ElevatedButton.icon(
                          onPressed: () => handleScan(expense),
                          label: Text('Upload receipt'),
                          icon: Icon(Icons.photo_camera),
                        ),
                      Flexible(
                          child: expense.hasNoItems
                              ? ListEmpty(text: 'Add items to this expense')
                              : ItemsList(expense: expense)),
                    ],
                  ),
          ),
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
            validators: [FieldData.requiredValidator],
          ),
          FieldData(
            id: "item_value",
            label: "Item Value",
            inputType: TextInputType.numberWithOptions(decimal: true),
            validators: [
              FieldData.requiredValidator,
              FieldData.doubleValidator
            ],
            formatters: [CommaReplacerTextInputFormatter()],
          ),
          FieldData(
            id: "item_partition",
            label: "Item Parts",
            inputType: TextInputType.number,
            initialData: 1,
            validators: [FieldData.requiredValidator, FieldData.intValidator],
            formatters: [FilteringTextInputFormatter.deny(RegExp('\.,-'))],
          ),
        ],
        onSubmit: (values) async {
          expense.addItem(Item(
            name: values["item_name"]!,
            value: double.parse(values["item_value"]!),
            partition: int.parse(values["item_partition"]!),
          ));
          await Firestore.instance.updateExpense(expense);
        },
      ),
    );
  }

  void handleScan(Expense expense) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null)
      throw new Exception("Something went wrong while taking a photo");

    var task = await FirebaseStorage.instance
        .ref(pickedFile.name)
        .putFile(File(pickedFile.path));

    String url = await task.ref.getDownloadURL();
    var getItemsFromImage =
        FirebaseFunctions.instance.httpsCallable('getReceiptData');

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
      await Firestore.instance.updateExpense(expense);
    }
  }
}
