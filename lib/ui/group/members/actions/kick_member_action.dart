import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';

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
    // final groupCubit = context.read<GroupCubit>();
    await showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to KICK member "${user.name}"',
        valueName: 'member name',
        value: user.name,
        onConfirm: () async {
          // await groupCubit.removeMember(user.uid);
          await _handleKickMember(context);
        },
      ),
    );
  }

  Future<void> _handleKickMember(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();

    // check if member is assignee in any outstanding expenses

    final hasOutstandingBalance =
        this.group.memberHasOutstandingBalance(user.uid);
    if (hasOutstandingBalance) {
      /// check if he is the author of the expense
      /// if yes -> allow leave
      ///
      /// if not -> do not allow kicking
      ///
      final expenses = await groupCubit.getExpensesForMember(user.uid);
      if (expenses.isNotEmpty) {
        /// display error
        /// or somehow notify the user
      }
    }

    await groupCubit.removeMember(user.uid);
  }
}
