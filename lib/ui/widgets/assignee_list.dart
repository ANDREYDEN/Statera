import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/expense_builder.dart';
import 'package:statera/ui/widgets/group_builder.dart';

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
                  children: expense.assignees.map((assignee) {
                    if (!group.userExists(assignee.uid))
                      return Icon(Icons.error);
                    var member = group.getUser(assignee.uid);
                    return AuthorAvatar(
                      margin: const EdgeInsets.only(right: 4),
                      author: member,
                      checked: expense.isMarkedBy(assignee.uid),
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
