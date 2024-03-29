import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/user_avatar.dart';
import 'package:statera/ui/expense/expense_builder.dart';
import 'package:statera/ui/group/group_builder.dart';

class AssigneeList extends StatelessWidget {
  const AssigneeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ExpenseBuilder(
              builder: (_, expense) => GroupBuilder(
                builder: (_, group) => ListView(
                  scrollDirection: Axis.horizontal,
                  children: expense.assigneeUids.map((assigneeUid) {
                    if (!group.memberExists(assigneeUid))
                      return Icon(Icons.error);
                    var member = group.getMember(assigneeUid);
                    return UserAvatar(
                      margin: const EdgeInsets.only(right: 4),
                      author: member,
                      withIcon: expense.isMarkedBy(assigneeUid),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
