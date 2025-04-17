import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class KickMemberAction extends MemberAction {
  final Group group;
  KickMemberAction(this.group, super.user);

  @override
  IconData get icon => Icons.person_off;

  @override
  String get name => 'Kick Member';

  @override
  Color? getIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  @override
  Future<void> handle(BuildContext context) async {
    String title = 'You are about to KICK member "${user.name}"';
    late String warningMessage;

    final groupService = context.read<ExpenseService>();
    final groupCubit = context.read<GroupCubit>();

    final hasOutstandingBalance =
        this.group.memberHasOutstandingBalance(user.uid);

    final membersThatMemberOwesTo =
        this.group.getMembersThatMemberOwesTo(user.uid);
    final memberNames = membersThatMemberOwesTo
        .map((memberId) => this.group.getMember(memberId).name)
        .join(', ');

    final pendingMemberExpenses = await groupService
        .getExpensesForMemberWhereAssignee(group.id!, user.uid, false);
    final pendingExpenseNames =
        pendingMemberExpenses.map((expense) => expense.name).join(', ');

    final expensesAuthor =
        await groupService.getAuthoredExpenses(group.id!, user.uid, false);
    final expensesAuthorNames = expensesAuthor.map((expense) => expense.name);

    if (hasOutstandingBalance || membersThatMemberOwesTo.isNotEmpty) {
      warningMessage = '''
      Warning! You are about to kick ${user.name} who is involved in outstanding expenses!
      This person has outstanding balance with ${memberNames}
      Pending expenses where user is involved: ${pendingExpenseNames}
      User is the author of unresolved expenses: ${expensesAuthorNames}
      ''';
    }

    await _showDangerDialog(warningMessage + title, context, groupCubit);
  }

  Future<void> _showDangerDialog(
      String title, BuildContext context, GroupCubit groupCubit) async {
    await showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: title,
        valueName: 'member name',
        value: user.name,
        onConfirm: () async {
          await groupCubit.removeMember(user.uid);
        },
      ),
    );
  }

  String _createMessage(){
    return '';
  }
}
