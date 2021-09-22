import 'package:flutter/material.dart';
import 'package:statera/models/group.dart';
import 'package:statera/views/group_page.dart';
import 'package:statera/widgets/unmarked_expenses_badge.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(GroupPage.route + '/${this.group.id}');
      },
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: UnmarkedExpensesBadge(
              groupId: this.group.id,
              child: Text(
                this.group.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
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
