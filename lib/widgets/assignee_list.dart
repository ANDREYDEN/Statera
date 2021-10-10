import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/widgets/author_avatar.dart';
import 'package:statera/widgets/custom_stream_builder.dart';

class AssigneeList extends StatelessWidget {
  const AssigneeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Expense expense = Provider.of<Expense>(context);

    return Container(
      height: 50,
      child: CustomStreamBuilder<Group>(
        stream: Firestore.instance.getExpenseGroupStream(expense),
        builder: (context, group) {
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
