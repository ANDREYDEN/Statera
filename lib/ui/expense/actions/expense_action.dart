import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/expense/dialogs/expense_dialogs.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/utils/utils.dart';

abstract class ExpenseAction {
  IconData get icon;
  String get name;

  Color? getIconColor(BuildContext context) => null;

  FutureOr<void> handle(BuildContext context, Expense expense);
}

class ShareExpenseAction extends ExpenseAction {
  @override
  IconData get icon => Icons.share;

  @override
  String get name => 'Share';

  @override
  FutureOr<void> handle(BuildContext context, Expense expense) async {
    await snackbarCatch(context, () async {
      final dynamicLinkRepository = context.read<DynamicLinkService>();
      final link = await dynamicLinkRepository.generateDynamicLink(
        path: ModalRoute.of(context)!.settings.name,
      );

      ClipboardData clipData = ClipboardData(text: link);
      await Clipboard.setData(clipData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard')),
      );
    });
  }
}

class SettingsExpenseAction extends ExpenseAction {
  @override
  IconData get icon => Icons.settings;

  @override
  String get name => 'Settings';

  @override
  handle(BuildContext context, Expense expense) {
    final authBloc = context.read<AuthBloc>();
    final expenseBloc = context.read<ExpenseBloc>();

    expenseBloc.add(
      UpdateRequested(
        issuerUid: authBloc.uid,
        update: (expense) => showDialog(
          context: context,
          builder: (_) => ExpenseSettingsDialog(expense: expense),
        ),
      ),
    );
  }
}

class DeleteExpenseAction extends ExpenseAction {
  @override
  IconData get icon => Icons.delete;

  @override
  String get name => 'Delete';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  handle(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        text:
            'Are you sure you want to delete this expense and all of its items?',
      ),
    );

    final expensesCubit = context.read<ExpensesCubit>();
    if (confirmed == true) expensesCubit.deleteExpense(expense);
  }
}
