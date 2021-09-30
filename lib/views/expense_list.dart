import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
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
        Expanded(child: buildExpensesList()),
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
