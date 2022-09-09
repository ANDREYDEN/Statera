import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/item.dart';
import 'package:statera/ui/expense/expense_action_handlers.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';
import 'package:statera/utils/utils.dart';

class ItemsList extends StatelessWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    return ExpenseBuilder(builder: (context, expense) {
      final expenseCanBeUpdated = expense.canBeUpdatedBy(authBloc.uid);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 20 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isWide && expenseCanBeUpdated)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () => handleNewItemClick(context),
                  child: Icon(Icons.add),
                ),
              ),
            Expanded(
              child: expense.hasNoItems
                  ? ListEmpty(text: 'Add items to this expense')
                  : ListView.builder(
                      itemCount: expense.items.length,
                      itemBuilder: (context, index) {
                        var item = expense.items[index];

                        return OptionallyDismissible(
                          key: Key(item.hashCode.toString()),
                          isDismissible: expense.canBeUpdatedBy(authBloc.uid),
                          onDismissed: (_) async {
                            expenseBloc.add(
                              UpdateRequested(
                                issuer: authBloc.user,
                                update: (expense) =>
                                    expense.items.removeAt(index),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GestureDetector(
                              onLongPress: expense.canBeUpdatedBy(authBloc.uid)
                                  ? () => _handleItemLongPress(
                                      context, expenseBloc, authBloc.user, item)
                                  : null,
                              child: ItemListItem(
                                item: item,
                                onChangePartition: !expense.finalized
                                    ? (parts) {
                                        expenseBloc.add(
                                          UpdateRequested(
                                            issuer: authBloc.user,
                                            update: (expense) {
                                              expense.items[index]
                                                  .setAssigneeDecision(
                                                      authBloc.uid, parts);
                                            },
                                          ),
                                        );
                                      }
                                    : (p) {},
                              ),
                            ),
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

  _handleItemLongPress(
    BuildContext context,
    ExpenseBloc expenseBloc,
    User user,
    Item item,
  ) {
    expenseBloc.add(
      UpdateRequested(
        issuer: user,
        update: (expense) async {
          await showDialog(
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
                  formatters: [CommaReplacerTextInputFormatter()],
                ),
              ],
              onSubmit: (values) async {
                item.name = values["item_name"]!;
                item.value = double.parse(values["item_value"]!);
                expense.updateItem(item);
              },
            ),
          );
        },
      ),
    );
  }
}
