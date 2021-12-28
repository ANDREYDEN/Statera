
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';

class AssigneeList extends StatelessWidget {
  const AssigneeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Expense expense = Provider.of<Expense>(context);

    return Container(
      height: 50,
      child: CustomStreamBuilder<Group?>(
        stream: GroupService.instance.getExpenseGroupStream(expense),
        builder: (context, group) {
          if (group == null) {
            return Text('Group does not exist');
          }
          return Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: expense.assignees.map((assignee) {
                    var member = group.getUser(assignee.uid);
                    if (member == null) return Icon(Icons.error);
                    return AuthorAvatar(
                      margin: const EdgeInsets.only(right: 4),
                      author: member,
                      checked: expense.isMarkedBy(assignee.uid),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
