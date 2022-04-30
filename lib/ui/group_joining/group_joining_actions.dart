import 'package:flutter/material.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/protected_elevated_button.dart';

class GroupJoiningActions extends StatelessWidget {
  final Future Function() onJoin;

  const GroupJoiningActions({Key? key, required this.onJoin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProtectedElevatedButton(
            onPressed: onJoin,
            child: Text('Join'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, GroupList.route);
            },
            child: Text('Cancel'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
