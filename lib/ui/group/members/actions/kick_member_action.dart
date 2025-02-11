import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';

class KickMemberAction extends MemberAction {
  KickMemberAction(super.user);

  @override
  IconData get icon => Icons.person_off;

  @override
  String get name => 'Kick Member';

  @override
  Color? getIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  @override
  Future<void> handle(BuildContext context) async {
    final groupCubit = context.read<GroupCubit>();
    await showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to KICK member "${user.name}"',
        valueName: 'memeber name',
        value: user.name,
        onConfirm: () async {
          await groupCubit.removeMember(user.uid);
        },
      ),
    );
  }
}
