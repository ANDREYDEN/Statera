import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/ui/groups/actions/user_group_action.dart';

class ToggleArchiveUserGroupAction extends UserGroupAction {
  ToggleArchiveUserGroupAction(super.userGroup);

  @override
  IconData get icon => userGroup.archived ? Icons.unarchive : Icons.archive;

  @override
  String get name => userGroup.archived ? 'Unarchive' : 'Archive';

  @override
  FutureOr<void> handle(BuildContext context) async {
    final groupsCubit = context.read<GroupsCubit>();
    final authBloc = context.read<AuthBloc>();
    userGroup.toggleArchive();
    await groupsCubit.update(authBloc.uid, userGroup);
  }
}
