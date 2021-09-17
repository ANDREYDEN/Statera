import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/group.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/group_page.dart';
import 'package:statera/widgets/unmarked_expenses_badge.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GroupViewModel groupVm = Provider.of<GroupViewModel>(context);

    return ListTile(
      onTap: () => groupVm.group = this.group,
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
