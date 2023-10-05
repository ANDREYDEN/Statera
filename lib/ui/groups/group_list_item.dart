import 'package:flutter/material.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(GroupPage.route + '/${this.group.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: UnmarkedExpensesBadge(
                        groupId: this.group.id,
                        child: Text(this.group.name,
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person),
                  Text(this.group.members.length.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
