import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/group.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/group_page.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Provider.of<GroupViewModel>(context, listen: false).group = this.group;
        Navigator.of(context).pushNamed(GroupPage.route);
      },
      title: Text(this.group.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person),
          Text(this.group.members.length.toString()),
        ],
      ),
    );
  }
}
