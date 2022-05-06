import 'package:flutter/material.dart';
import 'package:statera/ui/groups/group_list.dart';

class GroupJoiningErrorState extends StatelessWidget {
  final String error;
  const GroupJoiningErrorState({Key? key, required this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(error),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            GroupList.route,
          ),
          child: Text('Back'),
        )
      ],
    );
  }
}
