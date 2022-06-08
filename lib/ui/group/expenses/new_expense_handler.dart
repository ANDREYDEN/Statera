import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/expense/expense_page.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

void handleNewExpenseClick(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isWide = context.read<LayoutState>().isWide;
    final groupCubit = context.read<GroupCubit>();
    final groupId = groupCubit.loadedState.group.id;
    final expensesCubit = context.read<ExpensesCubit>();

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense Name",
            validators: [FieldData.requiredValidator],
          )
        ],
        closeAfterSubmit: false,
        onSubmit: (values) async {
          var newExpense = Expense(
            author: Author.fromUser(authBloc.user),
            name: values["expense_name"]!,
            groupId: groupId,
          );
          final expenseId = await expensesCubit.addExpense(newExpense, groupId);
          if (isWide) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context)
                .popAndPushNamed('${ExpensePage.route}/$expenseId');
          }
        },
      ),
    );
  }