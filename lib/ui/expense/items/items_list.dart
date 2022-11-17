import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/expense/expense_action_handlers.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

class ItemsList extends StatelessWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
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
                  onPressed: () => handleItemUpsert(context),
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
                          onDismissed: (_) => _handleItemDelete(context, index),
                          confirmation:
                              'Are you sure you want to delete this item?',
                          child: ItemListItem(
                            onLongPress: expense.canBeUpdatedBy(authBloc.uid)
                                ? () => handleItemUpsert(
                                      context,
                                      intialItem: item,
                                    )
                                : null,
                            item: item,
                            onChangePartition: !expense.finalized
                                ? (partition) => _handleItemPartitionChange(
                                      context,
                                      partition,
                                      index,
                                    )
                                : (p) {},
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

  void _handleItemDelete(BuildContext context, int index) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();
    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.user,
        update: (expense) => expense.items.removeAt(index),
      ),
    );
  }

  void _handleItemPartitionChange(BuildContext context, int parts, int index) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();
    expenseBloc.add(
      UpdateRequested(
        issuer: authBloc.user,
        update: (expense) {
          expense.items[index].setAssigneeDecision(authBloc.uid, parts);
        },
      ),
    );
  }
}
