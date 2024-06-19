import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/ui/groups/actions/user_group_action.dart';

class TogglePinUserGroupAction extends UserGroupAction {
  TogglePinUserGroupAction(super.userGroup);

  @override
  IconData get icon => Icons.push_pin;

  @override
  String get name => userGroup.pinned ? 'Unpin' : 'Pin';

  @override
  FutureOr<void> handle(BuildContext context) async {
    final groupsCubit = context.read<GroupsCubit>();
    final authBloc = context.read<AuthBloc>();
    userGroup.pinned = !userGroup.pinned;
    await groupsCubit.update(authBloc.uid, userGroup);
  }
}
