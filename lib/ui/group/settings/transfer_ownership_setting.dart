import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class TransferOwnershipSetting extends StatelessWidget {
  final String groupName;

  const TransferOwnershipSetting({
    Key? key,
    required this.groupName,
  }) : super(key: key);

  void _handleTransferOwnership(BuildContext context) async {
    final layoutState = context.read<LayoutState>();
    final groupCubit = context.read<GroupCubit>();

    final newAuthorUid = await showDialog<String?>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          Provider<LayoutState>.value(value: layoutState),
          BlocProvider<GroupCubit>.value(value: groupCubit)
        ],
        child: MemberSelectDialog(
          title:
              'Select a member to TRASFER OWNERSHIP of group "$groupName" to',
          singleSelection: true,
          excludeMe: true,
        ),
      ),
    );

    if (newAuthorUid != null) {
      groupCubit.update((group) {
        group.adminUid = newAuthorUid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Transfer group ownership'),
      subtitle: Text('Choose another group member to take charge.'),
      trailing: DangerButton(
        text: 'Transfer ownership',
        onPressed: () => _handleTransferOwnership(context),
      ),
    );
  }
}
