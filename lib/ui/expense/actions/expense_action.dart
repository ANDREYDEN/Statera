import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/expense/expense_bloc.dart';
import 'package:statera/business_logic/expenses/expenses_cubit.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';
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
        title: 'Delete expense',
        text:
            'Are you sure you want to delete this expense and all of its items?',
      ),
    );

    final expensesCubit = context.read<ExpensesCubit>();
    if (confirmed == true) expensesCubit.deleteExpense(expense);
  }
}

class RevertExpenseAction extends ExpenseAction {
  @override
  IconData get icon => Icons.undo;

  @override
  String get name => 'Revert';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  handle(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => OKCancelDialog(
        title: 'Revert expense',
        text:
            'Are you sure you want to revert this expense? All members that took part in this expense will be refunded and the expense will become active again.',
      ),
    );

    if (confirmed == false) return;

    final groupCubit = context.read<GroupCubit>();
    final expenseService = context.read<ExpenseService>();
    final paymentService = context.read<PaymentService>();

    // TODO: use transaction
    final group = groupCubit.loadedState.group;

    await expenseService.revertExpense(expense);
    // add expense payments from all assignees to author
    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
          (assigneeUid) => Payment(
            groupId: expense.groupId,
            payerId: assigneeUid,
            receiverId: expense.authorUid,
            value: expense.getConfirmedTotalForUser(assigneeUid),
            relatedExpense: PaymentExpenseInfo.fromExpense(expense),
            oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
            newFor: [assigneeUid],
          ),
        );
    await Future.wait(payments.map(paymentService.addPayment));
    // try {
    //   Callables.notifyWhenExpenseReverted(expenseId: expense.id);
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
    groupCubit.update((group) {
      for (var payment in payments) {
        group.payOffBalance(payment: payment);
      }
    });
  }
}
