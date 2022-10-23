import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/danger_zone.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/section_title.dart';

class GroupSettings extends StatelessWidget {
  const GroupSettings({Key? key}) : super(key: key);

  void _handleTransferOwnership(BuildContext context, String groupName) async {
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();

    final newAuthor = await showDialog<Author?>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          Provider<LayoutState>.value(value: layoutState),
          BlocProvider<GroupCubit>.value(value: groupCubit)
        ],
        child: MemberSelectDialog(
          title:
              'Select a member to TRASFER OWNERSHIP of group "$groupName" to',
        ),
      ),
    );

    if (newAuthor != null) {
      groupCubit.update((group) {
        group.adminUid = newAuthor.uid;
      });
    }
  }

  void _handleLeave(BuildContext context, String groupName) {
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
            groupCubit.removeUser(authBloc.uid);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, String groupName) {
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
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    final currencyController = TextEditingController();
    final nameController = TextEditingController();
    final debtThresholdController = TextEditingController();

    return GroupBuilder(
      builder: (context, group) {
        currencyController.text = group.currencySign;
        nameController.text = group.name;
        debtThresholdController.text = group.debtThreshold.toString();
        final isAdmin = group.isAdmin(uid);

        return Container(
          padding: EdgeInsets.all(20),
          width:
              layoutState.isWide ? MediaQuery.of(context).size.width / 3 : null,
          child: ListView(
            children: [
              if (isAdmin) ...[
                SectionTitle('General Settings'),
                // TODO: validate these fields the same way as in the CRUD Dialog
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  onSubmitted: (value) {
                    final groupCubit = context.read<GroupCubit>();

                    groupCubit.update((group) {
                      group.name = value;
                    });
                  },
                ),
                TextField(
                  controller: currencyController,
                  decoration: InputDecoration(labelText: 'Currency Sign'),
                  onSubmitted: (value) {
                    groupCubit.update((group) {
                      group.currencySign = value;
                    });
                  },
                ),
                TextField(
                  controller: debtThresholdController,
                  decoration: InputDecoration(labelText: 'Debt Threshold'),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp('-'))
                  ],
                  onSubmitted: (value) {
                    groupCubit.update((group) {
                      group.debtThreshold = double.parse(value);
                    });
                  },
                ),
                SizedBox(height: 40),
              ],
              DangerZone(
                children: [
                  if (isAdmin)
                    ListTile(
                      title: Text('Transfer group ownership'),
                      subtitle:
                          Text('Choose another group member to take charge.'),
                      trailing: DangerButton(
                        text: 'Transfer ownership',
                        onPressed: () =>
                            _handleTransferOwnership(context, group.name),
                      ),
                    ),
                  ListTile(
                    title: Text('Leave the group'),
                    subtitle: Text(
                      'You can only leave the group if your balance is resolved and you are not part of any outstanding expenses. If you are a group admin, you need to transfer ownership before leaving.',
                    ),
                    trailing: DangerButton(
                      text: 'Leave group',
                      onPressed: isAdmin
                          ? null
                          : () => _handleLeave(context, group.name),
                    ),
                  ),
                  if (isAdmin)
                    ListTile(
                      title: Text('Delete the group'),
                      subtitle: Text(
                          'Deleting the group will erase all group data. There is no way to undo this action.'),
                      trailing: DangerButton(
                        onPressed: () => _handleDelete(context, group.name),
                        text: 'Delete group',
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
