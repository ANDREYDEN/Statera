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
  final Expense expense;

  ExpenseAction(this.expense);

  IconData get icon;
  String get name;

  Color? getIconColor(BuildContext context) => null;

  FutureOr<void> handle(BuildContext context);
}

class ShareExpenseAction extends ExpenseAction {
  ShareExpenseAction(super.expense);

  @override
  IconData get icon => Icons.share;

  @override
  String get name => 'Share';

  @override
  FutureOr<void> handle(BuildContext context) async {
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
  SettingsExpenseAction(super.expense);

  @override
  IconData get icon => Icons.settings;

  @override
  String get name => 'Settings';

  @override
  FutureOr<void> handle(BuildContext context) {
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
  DeleteExpenseAction(super.expense);

  @override
  IconData get icon => Icons.delete;

  @override
  String get name => 'Delete';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  FutureOr<void> handle(BuildContext context) async {
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

class FinalizeExpenseAction extends ExpenseAction {
  FinalizeExpenseAction(super.expense);

  @override
  IconData get icon => Icons.done;

  @override
  String get name => 'Finalize';

  @override
  handle(BuildContext context) async {
    final valid = await verifyAllItemsValid(context);
    if (!valid) return;

    snackbarCatch(
      context,
      () async {
        final groupCubit = context.read<GroupCubit>();
        final expenseService = context.read<ExpenseService>();

        // TODO: use transaction
        var group = groupCubit.loadedState.group;

        await expenseService.finalizeExpense(expense);
        final payments = await createPayments(context, group);
        updateGroup(groupCubit, payments);
      },
      successMessage:
          "The expense is now finalized. Participants' balances updated.",
    );
  }

  Future<bool> verifyAllItemsValid(BuildContext context) async {
    bool accepted = true;
    if (expense.hasItemsDeniedByAll) {
      accepted = await showDialog<bool>(
            context: context,
            builder: (context) => OKCancelDialog(
              title: 'Some items require attention',
              text:
                  'This expense contains items that were not marked by any of the assignees. This means that you will not be reimbursed for these items from anyone in the group. Are you sure you still want to finalize the expense?',
            ),
          ) ??
          false;
    }

    return accepted;
  }

  /// Add expense payments from author to all assignees
  Future<List<Payment>> createPayments(
      BuildContext context, Group group) async {
    final paymentService = context.read<PaymentService>();

    final payments = expense.assigneeUids
        .where((assigneeUid) => assigneeUid != expense.authorUid)
        .map(
      (assigneeUid) {
        return Payment.fromFinalizedExpense(
          expense: expense,
          receiverId: assigneeUid,
          oldAuthorBalance: group.balance[expense.authorUid]?[assigneeUid],
        );
      },
    );
    await Future.wait(payments.map(paymentService.addPayment));
    return payments.toList();
  }

  void updateGroup(GroupCubit groupCubit, List<Payment> payments) {
    groupCubit.update((group) {
      for (var payment in payments) {
        group.payOffBalance(payment: payment);
      }
    });
  }
}

class RevertExpenseAction extends ExpenseAction {
  RevertExpenseAction(super.expense);

  @override
  IconData get icon => Icons.undo;

  @override
  String get name => 'Revert';

  @override
  Color? getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  @override
  handle(BuildContext context) async {
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
          (assigneeUid) => Payment.fromRevertedExpense(
            expense: expense,
            payerId: assigneeUid,
            oldPayerBalance: group.balance[assigneeUid]?[expense.authorUid],
          ),
        );
    await Future.wait(payments.map(paymentService.addPayment));

    groupCubit.update((group) {
      for (var payment in payments) {
        group.payOffBalance(payment: payment);
      }
    });
  }
}
