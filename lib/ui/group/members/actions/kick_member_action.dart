import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

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

    final expenseService = context.read<ExpenseService>();
    final groupCubit = context.read<GroupCubit>();

    final hasOutstandingBalance =
        this.group.memberHasOutstandingBalance(user.uid);

    final membersThatMemberOwesTo =
        this.group.getMembersThatMemberOwesTo(user.uid);
    final members = membersThatMemberOwesTo
        .map((memberId) => this.group.getMember(memberId))
        .toList();
    final memberNames = membersThatMemberOwesTo
        .map((memberId) => this.group.getMember(memberId).name)
        .join(', ');

    final pendingMemberExpenses =
        await expenseService.getPendingExpenses(group.id!, user.uid);
    final pendingExpenseNames =
        pendingMemberExpenses.map((expense) => expense.name).join(', ');

    final expensesAuthor =
        await expenseService.getPendingAuthoredExpenses(group.id!, user.uid);
    final expensesAuthorNames = expensesAuthor.map((expense) => expense.name);

    if (hasOutstandingBalance ||
        membersThatMemberOwesTo.isNotEmpty ||
        pendingMemberExpenses.isNotEmpty ||
        expensesAuthor.isNotEmpty) {
      warningMessage = _createMessage(
        hasOutstandingBalance: hasOutstandingBalance,
        memberNames: memberNames,
        pendingExpenseNames: pendingExpenseNames,
        expensesAuthorNames: expensesAuthorNames,
      );
    }

    await _showDangerDialog(title, members, pendingMemberExpenses,
        expensesAuthor, context, groupCubit);
  }

  Future<void> _showDangerDialog(
      String title,
      List<CustomUser> members,
      List<Expense> pendingMemberExpenses,
      List<Expense> pendingAuthoredMemberExpenses,
      BuildContext context,
      GroupCubit groupCubit) async {
    await showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: title,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This person has outstanding balance with',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              height: 70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: members.map((member) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: UserAvatar(author: member, withName: true),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Pending expenses where user is involved',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: pendingMemberExpenses.map((expense) {
                  return Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          expense.name,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Pending expenses where user is author',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: pendingAuthoredMemberExpenses.map((expense) {
                  return Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          expense.name,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
        valueName: 'member name',
        value: user.name,
        onConfirm: () async {
          await groupCubit.removeMember(user.uid);
        },
      ),
    );
  }

  String _createMessage({
    required bool hasOutstandingBalance,
    required String memberNames,
    required String pendingExpenseNames,
    required Iterable<String> expensesAuthorNames,
  }) {
    final List<String> messageParts = [];

    if (memberNames.isNotEmpty) {
      messageParts
          .add('This person has outstanding balance with $memberNames.');
    }

    if (pendingExpenseNames.isNotEmpty) {
      messageParts.add(
          'Pending expenses where user is involved: $pendingExpenseNames.');
    }

    if (expensesAuthorNames.isNotEmpty) {
      messageParts.add(
          'User is the author of unresolved expenses: ${expensesAuthorNames.join(', ')}.');
    }

    if (messageParts.isEmpty) {
      return '';
    }

    return '\n\n' + messageParts.join('\n');
  }
}
