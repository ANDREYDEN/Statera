import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class GroupJoiningActions extends StatelessWidget {
  final String? code;

  const GroupJoiningActions({Key? key, this.code})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    GroupCubit groupCubit = context.read<GroupCubit>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);

    return Row(
      children: [
        Expanded(
          child: ProtectedButton(
            onPressed: () {
              groupCubit.join(code, uid);
            },
            child: Text('Join'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CancelButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, GroupList.route);
            },
          ),
        ),
      ],
    );
  }
}
