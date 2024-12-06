import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/group_page.dart';
import 'package:statera/ui/groups/actions/toggle_archive_user_group_action.dart';
import 'package:statera/ui/groups/actions/toggle_pin_user_group_action.dart';
import 'package:statera/ui/groups/group_list_item/member_debt_indicator.dart';
import 'package:statera/ui/widgets/buttons/actions_button.dart';

class GroupListItem extends StatelessWidget {
  final UserGroup userGroup;

  const GroupListItem({Key? key, required this.userGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          context.go(GroupPage.route + '/${this.userGroup.groupId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userGroup.pinned) ...[
                      Icon(Icons.push_pin),
                      SizedBox(width: 5)
                    ],
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Badge.count(
                            count: userGroup.unmarkedExpenses,
                            isLabelVisible: userGroup.unmarkedExpenses > 0,
                            child: Text(
                              userGroup.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              MemberDebtIndicator.outward(userGroup: userGroup),
                              MemberDebtIndicator.inward(userGroup: userGroup),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person),
                  Text(userGroup.memberCount.toString()),
                ],
              ),
              ActionsButton(
                tooltip: 'Group actions',
                actions: [
                  if (!userGroup.archived) TogglePinUserGroupAction(userGroup),
                  ToggleArchiveUserGroupAction(userGroup),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
