import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';

class DeleteGroupSetting extends StatelessWidget {
  final String groupName;

  const DeleteGroupSetting({
    Key? key,
    required this.groupName,
  }) : super(key: key);

  void _handleDelete(BuildContext context) {
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();

    showDialog<bool>(
      context: context,
      builder: (context) => Provider<LayoutState>.value(
        value: layoutState,
        child: DangerDialog(
          title: 'You are about to DELETE the group "$groupName"',
          valueName: 'group name',
          value: groupName,
          onConfirm: () {
            groupCubit.delete();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Delete the group'),
      subtitle: Text(
          'Deleting the group will erase all group data. There is no way to undo this action.'),
      trailing: DangerButton(
        onPressed: () => _handleDelete(context),
        text: 'Delete group',
      ),
    );
  }
}
