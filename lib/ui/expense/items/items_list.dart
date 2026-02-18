import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/empty_expense_items_list.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/expense/items/item_action.dart';
import 'package:statera/ui/expense/items/item_list_item.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

class ItemsList extends StatelessWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.select((LayoutState state) => state.isWide);

    return ExpenseBuilder(
      builder: (context, expense) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 20 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: expense.hasNoItems
                    ? EmptyExpenseItemsList(expense: expense)
                    : ListView.builder(
                        itemCount: expense.items.length,
                        itemBuilder: (context, index) {
                          var item = expense.items[index];

                          return OptionallyDismissible(
                            key: Key(item.hashCode.toString()),
                            isDismissible: expense.canBeUpdatedBy(authBloc.uid),
                            onDismissed: (_) =>
                                _handleItemDelete(context, expense, index),
                            confirmation:
                                'Are you sure you want to delete this item?',
                            child: ItemListItemFactory.create(
                              item: item,
                              showDecisions: expense.settings.showItemDecisions,
                              onLongPress: expense.canBeUpdatedBy(authBloc.uid)
                                  ? () => UpsertItemAction(
                                      item: item,
                                    ).safeHandle(context)
                                  : null,
                              onChangePartition: !expense.finalized
                                  ? (partition) => _handleItemPartitionChange(
                                      context,
                                      expense,
                                      partition,
                                      index,
                                    )
                                  : (p) {},
                              expenseTax: expense.settings.tax,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleItemDelete(BuildContext context, Expense expense, int index) {
    final expenseBloc = context.read<ExpenseBloc>();

    final updatedExpense = expense..items.removeAt(index);

    expenseBloc.add(UpdateRequested(updatedExpense: updatedExpense));
  }

  void _handleItemPartitionChange(
    BuildContext context,
    Expense expense,
    int parts,
    int index,
  ) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    final updatedExpense = expense
      ..items[index].setAssigneeDecision(authBloc.uid, parts);

    expenseBloc.add(UpdateRequested(updatedExpense: updatedExpense));
  }
}
