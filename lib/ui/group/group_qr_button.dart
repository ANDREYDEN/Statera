import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/group_invite_dialog.dart';

class GroupQRButton extends StatelessWidget {
  const GroupQRButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.watch<GroupCubit>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return GroupBuilder(
      builder: (context, group) {
        final isAdmin = group.isAdmin(uid);

        if (!isAdmin) return SizedBox.shrink();

        return IconButton(
          icon: Icon(Icons.qr_code_rounded),
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
        );
      },
    );
  }
}
