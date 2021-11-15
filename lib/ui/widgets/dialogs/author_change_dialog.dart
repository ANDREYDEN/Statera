
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
class AuthorChangeDialog extends StatelessWidget {
  final Expense expense;

  const AuthorChangeDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign payer'),
      content: Container(
        width: 200,
        child: CustomStreamBuilder<Group>(
          stream: GroupService.instance.getExpenseGroupStream(this.expense),
          builder: (context, group) {
            return ListView.builder(
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final authorOption = group.members[index];
                return AuthorAvatar(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  onTap: () => Navigator.pop(context, authorOption),
                  author: authorOption,
                  withName: true,
                  checked: authorOption.uid == this.expense.author.uid,
                );
              },
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
