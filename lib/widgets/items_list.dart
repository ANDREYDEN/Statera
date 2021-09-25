import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:statera/models/expense.dart';
import 'package:statera/models/item.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/formatters.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/dialogs/crud_dialog.dart';
import 'package:statera/widgets/listItems/item_list_item.dart';
import 'package:statera/widgets/optionally_dismissible.dart';

class ItemsList extends StatelessWidget {
  final Expense expense;

  const ItemsList({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationViewModel authVm =
        Provider.of<AuthenticationViewModel>(context, listen: false);

    return ListView.builder(
      itemCount: this.expense.items.length,
      itemBuilder: (context, index) {
        var item = this.expense.items[index];

        // TODO: make this conditionally dismissable if finalized
        return OptionallyDismissible(
          key: Key(item.hashCode.toString()),
          isDismissible: authVm.canUpdate(this.expense),
          onDismissed: (_) async {
            this.expense.items.removeAt(index);
            await Firestore.instance.updateExpense(this.expense);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onLongPress: () => handleEditItem(
                context,
                item,
                authVm,
              ),
              child: ItemListItem(
                item: item,
                onChangePartition: (parts) async {
                  if (!authVm.canMark(expense)) return;

                  expense.items[index].setAssigneeDecision(
                    authVm.user.uid,
                    parts,
                  );
                  await Firestore.instance.updateExpense(expense);
                  // TODO: convert into a cloud function
                  if (expense.completed) {
                    snackbarCatch(
                      context,
                      () async {
                        final group = await Firestore.instance
                            .getExpenseGroupStream(expense)
                            .first;
                        group.updateBalance(expense);
                        await Firestore.instance.saveGroup(group);
                      },
                      successMessage:
                          "The expense is now complete. Participants' balances updated.",
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  handleEditItem(
    BuildContext context,
    Item item,
    AuthenticationViewModel authVm,
  ) {
    if (!authVm.canUpdate(this.expense)) return;

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Item",
        fields: [
          FieldData(
            id: "item_name",
            label: "Item Name",
            initialData: item.name,
            validators: [FieldData.requiredValidator],
          ),
          FieldData(
              id: "item_value",
              label: "Item Value",
              initialData: item.value,
              inputType: TextInputType.numberWithOptions(decimal: true),
              validators: [
                FieldData.requiredValidator,
                FieldData.doubleValidator
              ],
              formatters: [
                CommaReplacerTextInputFormatter()
              ]),
        ],
        onSubmit: (values) async {
          item.name = values["item_name"]!;
          item.value = double.parse(values["item_value"]!);
          this.expense.updateItem(item);
          await Firestore.instance.updateExpense(this.expense);
        },
      ),
    );
  }
}