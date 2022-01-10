import 'package:flutter/material.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/group/group_builder.dart';

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
        child: GroupBuilder(
          builder: (context, group) => ListView.builder(
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
          ),
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
