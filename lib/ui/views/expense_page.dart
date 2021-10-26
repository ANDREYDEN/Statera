import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/assignee_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/assignee_picker_dialog.dart';
import 'package:statera/ui/widgets/dialogs/author_change_dialog.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/dialogs/receipt_scan_dialog.dart';
import 'package:statera/ui/widgets/items_list.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/formatters.dart';
import 'package:statera/utils/helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Expense>.value(
      value: Firestore.instance.listenForExpense(widget.expenseId),
      initialData: Expense.empty(),
      // catchError: (context, error) => Text(error.toString()),
      child: Consumer<Expense>(
        builder: (context, expense, _) {
          return PageScaffold(
            onFabPressed: authVm.canUpdate(expense)
                ? () => handleCreateItem(expense)
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ExpenseStages(expense: expense),
                Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          authVm.getExpenseColor(expense),
                          Theme.of(context).colorScheme.surface,
                        ],
                        stops: [0, 0.8],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  expense.name,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Card(
                                color: Colors.grey[600],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    toStringPrice(expense.total),
                                    style: TextStyle(color: Colors.white),
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
                              if (!expense.canBeUpdatedBy(authVm.user.uid))
                                return;

                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate:
                                    DateTime.fromMillisecondsSinceEpoch(0),
                                lastDate: DateTime.now().add(
                                  Duration(days: 30),
                                ),
                              );

                              if (newDate == null) return;

                              expense.date = newDate;
                              await Firestore.instance.updateExpense(expense);
                            },
                            child: Text(
                              toStringDate(expense.date) ?? 'Not set',
                            ),
                          ),
                        ],
                      ),
                      Text("Payer:"),
                      AuthorAvatar(
                        author: expense.author,
                        onTap: () async {
                          if (!expense.canBeUpdatedBy(authVm.user.uid)) return;

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
                      onPressed: () => showDialog(
                            context: context,
                            builder: (_) => ReceiptScanDialog(expense: expense),
                          ),
                      label: Text('Upload receipt'),
                      icon: Icon(Icons.photo_camera)),
                Flexible(
                  child: expense.hasNoItems
                      ? ListEmpty(text: 'Add items to this expense')
                      : ItemsList(),
                ),
              ],
            ),
          );
        },
      ),
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
}
