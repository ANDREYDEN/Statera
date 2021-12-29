import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/widgets/assignee_list.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/items_list.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/price_text.dart';
import 'package:statera/utils/utils.dart';

class ExpensePage extends StatelessWidget {
  static const String route = "/expense";

  final String? expenseId;
  const ExpensePage({Key? key, required this.expenseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthenticationViewModel>(context, listen: false);
    return Consumer<Expense>(
      builder: (context, expense, _) {
        return PageScaffold(
          onFabPressed: authVm.canUpdate(expense)
              ? () => _handleCreateItem(context, expense)
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
                                child: PriceText(
                                  value: expense.total,
                                  textStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 20),
                            TextButton(
                              onPressed: _expenseAction(
                                context,
                                expense,
                                authVm,
                                () async {
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
                                  await ExpenseService.instance
                                      .updateExpense(expense);
                                },
                              ),
                              child: Text(
                                toStringDate(expense.date) ?? 'Not set',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AuthorAvatar(
                              author: expense.author,
                              onTap: _expenseAction(
                                context,
                                expense,
                                authVm,
                                () async {
                                  Author? newAuthor = await showDialog<Author>(
                                    context: context,
                                    builder: (context) => AuthorChangeDialog(
                                      expense: expense,
                                    ),
                                  );

                                  if (newAuthor == null) return;

                                  expense.author = newAuthor;
                                  await ExpenseService.instance
                                      .updateExpense(expense);
                                },
                              ),
                            ),
                            Icon(Icons.arrow_forward),
                            Expanded(
                              child: GestureDetector(
                                onTap: _expenseAction(
                                  context,
                                  expense,
                                  authVm,
                                  () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AssigneePickerDialog(
                                        expense: expense,
                                      ),
                                    );
                                  },
                                ),
                                child: AssigneeList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (expense.hasNoItems)
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ReceiptScanDialog(expense: expense),
                  ),
                  label: Text('Upload receipt'),
                  icon: Icon(Icons.photo_camera),
                ),
              Flexible(
                child: expense.hasNoItems
                    ? ListEmpty(text: 'Add items to this expense')
                    : ItemsList(),
              ),
            ],
          ),
        );
      },
    );
  }

  _handleCreateItem(BuildContext context, Expense expense) {
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
          await ExpenseService.instance.updateExpense(expense);
        },
        allowAddAnother: true,
      ),
    );
  }

  _expenseAction(
    BuildContext context,
    Expense expense,
    AuthenticationViewModel authVm,
    Function action,
  ) {
    return () {
      if (!expense.canBeUpdatedBy(authVm.user.uid)) {
        final reason = expense.completed
            ? 'This expense can no longer be edited'
            : "You don't have permission to edit this expense";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(reason),
          duration: Duration(seconds: 1),
        ));
        return;
      }
      action();
    };
  }
}
