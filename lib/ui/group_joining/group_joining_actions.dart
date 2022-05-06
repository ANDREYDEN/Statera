import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_elevated_button.dart';

class GroupJoiningActions extends StatelessWidget {
  final String? code;
  final User user;

  const GroupJoiningActions({Key? key, this.code, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    GroupCubit groupCubit = context.read<GroupCubit>();

    return Row(
      children: [
        Expanded(
          child: ProtectedElevatedButton(
            onPressed: () {
              groupCubit.join(code, user);
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
