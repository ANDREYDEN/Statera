import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/custom_user.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';
import 'package:statera/ui/widgets/entity_action.dart';

class KickMemberAction extends EntityAction {
  final CustomUser user;
  KickMemberAction({
    Key? key,
    required this.user,
  }) : super();

  @override
  IconData get icon => Icons.person_off;

  @override
  String get name => 'Kick';

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
