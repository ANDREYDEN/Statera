import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/group/members/kick_member/kick_member_info_section.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class KickMemberDialog extends StatelessWidget {
  final CustomUser member;
  final List<CustomUser> outstandingBalanceMembers;
  final List<Expense> pendingExpenses;
  final List<Expense> pendingAuthoredExpenses;

  const KickMemberDialog({
    super.key,
    required this.member,
    required this.outstandingBalanceMembers,
    required this.pendingExpenses,
    required this.pendingAuthoredExpenses,
  });

  static Future<void> show(
    BuildContext context, {
    required CustomUser member,
    required List<CustomUser> outstandingBalanceMembers,
    required List<Expense> pendingExpenses,
    required List<Expense> pendingAuthoredExpenses,
  }) {
    return showDialog(
      context: context,
      builder: (context) => KickMemberDialog(
        member: member,
        outstandingBalanceMembers: outstandingBalanceMembers,
        pendingExpenses: pendingExpenses,
        pendingAuthoredExpenses: pendingAuthoredExpenses,
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    final groupCubit = context.read<GroupCubit>();
    await groupCubit.removeMember(member.uid);
  }

  @override
  Widget build(BuildContext context) {
    String title = 'You are about to KICK member "${member.name}"';
    return DangerDialog(
      title: title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KickMemberInfoSection(
            title: 'Outstanding Balance',
            subtitle:
                'Below are other members that "${member.name}" has an outstanding balance with. This balance will disappear after the member is removed.',
            children: outstandingBalanceMembers.map((member) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserAvatar(author: member, withName: true),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          KickMemberInfoSection(
            title: 'Pending Expenses',
            subtitle:
                'Below are pending expenses where "${member.name}" is a participant. They will be removed from these expenses.',
            children: pendingExpenses.map((expense) {
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
          SizedBox(height: 16),
          KickMemberInfoSection(
            title: 'Pending Authored Expenses',
            subtitle:
                'Below are pending expenses where "${member.name}" is the author. These expenses will be deleted after the member is removed.',
            children: pendingAuthoredExpenses.map((expense) {
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
        ],
      ),
      valueName: 'member name',
      value: member.name,
      onConfirm: () => _handleConfirm(context),
    );
  }
}
