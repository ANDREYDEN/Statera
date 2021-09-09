import 'package:flutter/material.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/widgets/author_avatar.dart';

class AuthorChangeDialog extends StatelessWidget {
  final Group group;
  final Expense expense;

  const AuthorChangeDialog({
    Key? key,
    required this.group,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign payer'),
      content: Container(
        width: 200,
        child: ListView.builder(
          itemCount: this.group.members.length,
          itemBuilder: (context, index) {
            final authorOption = this.group.members[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AuthorAvatar(
                onTap: () => Navigator.pop(context, authorOption),
                author: authorOption,
                withName: true,
                checked: authorOption.uid == this.expense.author.uid,
              ),
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
