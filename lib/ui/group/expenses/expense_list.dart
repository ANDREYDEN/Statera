import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/expense_service.dart';
import 'package:statera/ui/group/expenses/expense_list_item.dart';
import 'package:statera/ui/widgets/custom_filter_chip.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/optionally_dismissible.dart';

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
  ExpensesCubit get expensesCubit => context.read<ExpensesCubit>();

  @override
  void initState() {
    super.initState();
    _filters = authBloc.state.user == null
        ? []
        : Expense.expenseStages(authBloc.state.user!.uid)
            .map((stage) => stage.name)
            .toList();
    _expenseStream = authBloc.state.user == null
        ? Stream.empty()
        : ExpenseService.instance.listenForRelatedExpenses(
            authBloc.state.user!.uid,
            groupCubit.loadedState.group.id,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (authBloc.state.user == null) return Text('Unauthorized');
    final uid = authBloc.state.user!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kIsWeb) SizedBox(height: 8),
        Row(
          children: [
            for (var stage in Expense.expenseStages(uid))
              Flexible(
                child: CustomFilterChip(
                  label: stage.name,
                  color: stage.color,
                  filtersList: _filters,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters.add(stage.name);
                      } else {
                        _filters.remove(stage.name);
                      }
                    });

                    expensesCubit.selectExpenseStages(uid, _filters);
                  },
                ),
              )
          ],
        ),
        if (authBloc.state.status == AuthStatus.authenticated)
          Expanded(
            child: BlocBuilder<ExpensesCubit, ExpensesState>(
              builder: (context, expensesState) {
                if (expensesState is ExpensesLoading) {
                  return Loader();
                }

                if (expensesState is ExpensesError) {
                  developer.log(
                    'Failed loading expenses',
                    error: expensesState.error,
                  );

                  return Center(child: Text(expensesState.error.toString()));
                }

                if (expensesState is ExpensesLoaded) {
                  final expenses = expensesState.expenses;
                  return Column(
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: Visibility(
                          visible: expensesState is ExpensesProcessing,
                          child: Loader(),
                        ),
                      ),
                      Expanded(
                        child: expenses.isEmpty
                            ? ListEmpty(text: "Start by adding an expense")
                            : ListView.builder(
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  var expense = expenses[index];

                                  return OptionallyDismissible(
                                    key: Key(expense.id!),
                                    isDismissible:
                                        expense.canBeUpdatedBy(authBloc.uid),
                                    confirmation:
                                        "Are you sure you want to delete this expense and all of its items?",
                                    onDismissed: (_) =>
                                        expensesCubit.deleteExpense(expense),
                                    child: GestureDetector(
                                      onLongPress: () =>
                                          handleEditExpense(expense),
                                      child: ExpenseListItem(expense: expense),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                return Container();
              },
            ),
          ),
      ],
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
