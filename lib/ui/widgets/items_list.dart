import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/listItems/item_list_item.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';
import 'package:statera/utils/formatters.dart';

class ItemsList extends StatelessWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc authBloc) => authBloc.state.user);
    Expense expense = Provider.of<Expense>(context);

    if (user == null) {
      return Container();
    }

    return ListView.builder(
      itemCount: expense.items.length,
      itemBuilder: (context, index) {
        var item = expense.items[index];

        return OptionallyDismissible(
          key: Key(item.hashCode.toString()),
          isDismissible: expense.canBeUpdatedBy(user.uid),
          onDismissed: (_) async {
            expense.items.removeAt(index);
            await ExpenseService.instance.updateExpense(expense);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onLongPress: () =>
                  handleEditItem(context, expense, item, user.uid),
              child: ItemListItem(
                item: item,
                onChangePartition: (parts) async {
                  if (!expense.canBeMarkedBy(user.uid)) return;

                  expense.items[index].setAssigneeDecision(user.uid, parts);
                  await ExpenseService.instance.updateExpense(expense);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  handleEditItem(BuildContext context, Expense expense, Item item, String uid) {
    if (!expense.canBeUpdatedBy(uid)) return;

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
          expense.updateItem(item);
          await ExpenseService.instance.updateExpense(expense);
        },
      ),
    );
  }
}
