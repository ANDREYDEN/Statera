import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/group/members/kick_member/kick_member_dialog.dart';

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
    final expenseService = context.read<ExpenseService>();

    final membersThatMemberOwesTo =
        this.group.getMembersThatMemberOwesTo(user.uid);
    final members = membersThatMemberOwesTo
        .map((memberId) => this.group.getMember(memberId))
        .toList();

    final pendingExpenses =
        await expenseService.getPendingExpenses(group.id!, user.uid);

    final pendingAuthoredExpenses =
        await expenseService.getPendingAuthoredExpenses(group.id!, user.uid);

    await KickMemberDialog.show(
      context,
      member: user,
      members: members,
      pendingExpenses: pendingExpenses,
      pendingAuthoredExpenses: pendingAuthoredExpenses,
    );
  }
}
