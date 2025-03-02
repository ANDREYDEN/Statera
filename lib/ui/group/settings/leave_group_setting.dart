import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';

class LeaveGroupSetting extends StatelessWidget {
  final bool isAdmin;
  final String groupName;

  const LeaveGroupSetting({
    Key? key,
    required this.isAdmin,
    required this.groupName,
  }) : super(key: key);

  Text generateSubtitle(BuildContext context, Group group) {
    final authBloc = context.read<AuthBloc>();
    return group.memberHasOutstandingBalance(authBloc.uid)
        ? Text('"Suck my ass" Oleksii Kvadrober')
        : Text(
            'You can only leave the group if your balance is resolved and you are not part of any outstanding expenses. If you are a group admin, you need to transfer ownership before leaving.');
  }

  void _handleLeave(BuildContext context, Group group) {
    final authBloc = context.read<AuthBloc>();
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();

    showDialog<bool>(
      context: context,
      builder: (context) => Provider<LayoutState>.value(
        value: layoutState,
        child: DangerDialog(
          title: 'You are about to LEAVE the group "$groupName"',
          valueName: 'group name',
          value: groupName,
          onConfirm: () {
            groupCubit.removeMember(authBloc.uid);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.select((AuthBloc authBloc) => authBloc.uid);

    return GroupBuilder(
      builder: (context, group) => ListTile(
        title: Text('Leave the group'),
        subtitle: generateSubtitle(context, group),
        trailing: DangerButton(
            text: 'Leave group',
            onPressed: isAdmin || group.memberHasOutstandingBalance(uid)
                ? null
                : () => _handleLeave(context, group)),
      ),
    );
  }
}
