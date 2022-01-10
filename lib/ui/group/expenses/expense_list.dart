import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/widgets/custom_filter_chip.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/group/expenses/expense_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';
import 'package:statera/utils/helpers.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  late Stream<List<Expense>> _expenseStream;
  List<String> _filters = [];

  AuthBloc get authBloc => context.read<AuthBloc>();

  GroupCubit get groupCubit => context.read<GroupCubit>();

  @override
  void initState() {
    super.initState();
    _filters = authBloc.expenseStages.map((stage) => stage.name).toList();
    _expenseStream = authBloc.state.user == null
        ? Stream.empty()
        : ExpenseService.instance.listenForRelatedExpenses(
            authBloc.state.user!.uid,
            groupCubit.loadedState.group.id,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        Row(
          children: [
            for (var stage in authBloc.expenseStages)
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
        if (authBloc.state.status == AuthStatus.authenticated)
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
            for (var stage in authBloc.expenseStages) {
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
                (expense) => authBloc.expenseStages.any(
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
                    isDismissible:
                        expense.canBeUpdatedBy(authBloc.state.user!.uid),
                    confirmation:
                        "Are you sure you want to delete this expense and all of its items?",
                    onDismissed: (_) {
                      ExpenseService.instance.deleteExpense(expense);
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
          await ExpenseService.instance.updateExpense(expense);
        },
      ),
    );
  }
}
