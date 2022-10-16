import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/danger_dialog.dart';
import 'package:statera/ui/widgets/section_title.dart';

class GroupSettings extends StatelessWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();
    final authBloc = context.read<AuthBloc>();

    final currencyController = TextEditingController();
    final nameController = TextEditingController();
    final debtThresholdController = TextEditingController();

    return GroupBuilder(
      builder: (context, group) {
        currencyController.text = group.currencySign;
        nameController.text = group.name;
        debtThresholdController.text = group.debtThreshold.toString();

        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            width: layoutState.isWide
                ? MediaQuery.of(context).size.width / 3
                : null,
            child: Column(
              children: [
                SectionTitle('Settings'),
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
                SectionTitle('Danger Zone'),
                TextButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => Provider<LayoutState>.value(
                        value: layoutState,
                        child: DangerDialog(
                          title:
                              'You are about to LEAVE the group "${group.name}"',
                          valueName: 'group name',
                          value: group.name,
                          onConfirm: () {
                            groupCubit.removeUser(authBloc.uid);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Leave group',
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => Provider<LayoutState>.value(
                        value: layoutState,
                        child: DangerDialog(
                          title:
                              'You are about to DELETE the group "${group.name}"',
                          valueName: 'group name',
                          value: group.name,
                          onConfirm: () {
                            groupCubit.removeUser(authBloc.uid);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Delete group',
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
