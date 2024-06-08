import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/groups/actions/archive_group_action.dart';
import 'package:statera/ui/widgets/buttons/actions_Button.dart';

class GroupListItem extends StatelessWidget {
  final UserGroup userGroup;

  const GroupListItem({Key? key, required this.userGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(GroupPage.route + '/${this.userGroup.groupId}');
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
                      child: Badge.count(
                        count: this.userGroup.unmarkedExpenses,
                        isLabelVisible: this.userGroup.unmarkedExpenses > 0,
                        child: Text(
                          this.userGroup.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person),
                  Text(this.userGroup.memberCount.toString()),
                ],
              ),
              ActionsButton(actions: [
                ToggleArchiveUserGroupAction(userGroup),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
