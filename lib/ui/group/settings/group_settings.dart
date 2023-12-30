import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/settings/debt_redirect_setting.dart';
import 'package:statera/ui/group/settings/delete_group_setting.dart';
import 'package:statera/ui/group/settings/leave_group_setting.dart';
import 'package:statera/ui/group/settings/transfer_ownership_setting.dart';
import 'package:statera/ui/widgets/danger_zone.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/inputs/setting_input.dart';
import 'package:statera/ui/widgets/section_title.dart';

class GroupSettings extends StatelessWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutState = context.read<LayoutState>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    final debtThresholdController = TextEditingController();

    return GroupBuilder(
      builder: (context, group) {
        debtThresholdController.text = group.debtThreshold.toString();
        final isAdmin = group.isAdmin(uid);

        return ListView(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal:
                layoutState.isWide ? MediaQuery.of(context).size.width / 4 : 20,
          ),
          children: [
            if (isAdmin) ...[
              SectionTitle('General Settings'),
              SettingInput(
                initialValue: group.name,
                label: 'Name',
                validators: [FieldData.requiredValidator],
                onPressed: (value) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.name = value;
                  });
                },
              ),
              SettingInput(
                initialValue: group.currencySign,
                label: 'Currency Sign',
                validators: [FieldData.requiredValidator],
                formatters: [LengthLimitingTextInputFormatter(1)],
                onPressed: (value) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.currencySign = value;
                  });
                },
              ),
              SettingInput(
                initialValue: group.debtThreshold.toString(),
                label: 'Debt Threshold',
                validators: [
                  FieldData.requiredValidator,
                  FieldData.intValidator
                ],
                formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
                onPressed: (value) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.debtThreshold = double.parse(value);
                  });
                },
              ),
              SizedBox(height: 20),
              SectionTitle('Default Expense Settings'),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  'Automatically add members who join the group to this expense',
                ),
                value: group.defaultExpenseSettings.acceptNewMembers,
                onChanged: (isOn) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.defaultExpenseSettings.acceptNewMembers = isOn;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Show how other people marked each item'),
                value: group.defaultExpenseSettings.showItemDecisions,
                onChanged: (isOn) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.defaultExpenseSettings.showItemDecisions = isOn;
                  });
                },
              ),
              SwitchListTile(
                title: Row(
                  children: [
                    Text('Apply tax to items'),
                    SizedBox(width: 5),
                    Tooltip(
                      message: 'You can change this for each item',
                      child: Icon(Icons.info, size: 20),
                    )
                  ],
                ),
                value: group.defaultExpenseSettings.tax != null,
                onChanged: (isOn) {
                  final groupCubit = context.read<GroupCubit>();

                  groupCubit.update((group) {
                    group.defaultExpenseSettings.tax = isOn ? 0.13 : null;
                  });
                },
              ),
              if (group.defaultExpenseSettings.tax != null) ...[
                SettingInput(
                  label: 'Amount of tax to apply',
                  initialValue: group.defaultExpenseSettings.tax.toString(),
                  formatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
                  validators: [FieldData.constrainedDoubleValidator(0, 1)],
                  onPressed: (value) {
                    final groupCubit = context.read<GroupCubit>();

                    groupCubit.update((group) {
                      group.defaultExpenseSettings.tax = double.parse(value);
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Items are taxable by default'),
                  value: group.defaultExpenseSettings.itemsAreTaxableByDefault,
                  onChanged: (isOn) {
                    final groupCubit = context.read<GroupCubit>();

                    groupCubit.update((group) {
                      group.defaultExpenseSettings.itemsAreTaxableByDefault =
                          isOn;
                    });
                  },
                ),
              ],
              SizedBox(height: 40),
              SectionTitle(
                'Beta Features',
                tooltipText: 'These settings are experimental',
              ),
              DebtRedirectSetting(group: group),
              SizedBox(height: 40),
            ],
            DangerZone(
              children: [
                if (isAdmin) TransferOwnershipSetting(groupName: group.name),
                LeaveGroupSetting(isAdmin: isAdmin, groupName: group.name),
                if (isAdmin) DeleteGroupSetting(groupName: group.name)
              ],
            ),
          ],
        );
      },
    );
  }
}
