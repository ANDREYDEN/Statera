import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';

class TransferOwnershipAction extends MemberAction {
  TransferOwnershipAction(super.user);

  @override
  IconData get icon => Icons.cached;

  @override
  String get name => 'Transfer Ownership';

  @override
  FutureOr<void> handle(BuildContext context) async {
    final groupCubit = context.read<GroupCubit>();
    await showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to Transfer Ownership to "${user.name}"',
        valueName: 'member name',
        value: user.name,
        onConfirm: () {
          groupCubit.update((group) {
            group.adminUid = this.user.uid;
          });
        },
      ),
    );
  }
}
