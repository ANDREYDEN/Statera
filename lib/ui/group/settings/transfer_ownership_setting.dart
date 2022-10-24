import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
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
