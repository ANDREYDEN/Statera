import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';
import 'package:statera/ui/widgets/section_title.dart';

class GroupSettings extends StatelessWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.read<GroupCubit>();
    final authBloc = context.read<AuthBloc>();
    final isWide = context.read<LayoutState>().isWide;

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
            width: isWide ? MediaQuery.of(context).size.width / 3 : null,
            child: Column(
              children: [
                SectionTitle('Settings'),
                // TODO: validate these fields the same way as in the CRUD Dialog
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  onSubmitted: (value) {
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
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp('-'))],
                  onSubmitted: (value) {
                    groupCubit.update((group) {
                      group.debtThreshold = double.parse(value);
                    });
                  },
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    var decision = await showDialog<bool>(
                      context: context,
                      builder: (context) => OKCancelDialog(
                        text: 'Are you sure you want to leave the group?',
                      ),
                    );
                    if (decision!) {
                      groupCubit.removeUser(authBloc.uid);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Leave group',
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
