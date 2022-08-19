import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/expense/dialogs/group_invite_dialog.dart';

class GroupQRButton extends StatelessWidget {
  const GroupQRButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.watch<GroupCubit>();

    return IconButton(
      onPressed: () async {
        showDialog(
          context: context,
          builder: (_) {
            final dialog = GroupInviteDialog(
              onGenerate: () {
                groupCubit.generateInviteLink();
              },
            );
            return BlocProvider<GroupCubit>.value(
              value: groupCubit,
              child: dialog,
            );
          },
        );
      },
      icon: Icon(Icons.qr_code_rounded),
    );
  }
}
