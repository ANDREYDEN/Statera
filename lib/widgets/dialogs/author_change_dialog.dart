import 'package:flutter/material.dart';
import 'package:statera/models/author.dart';
import 'package:statera/widgets/author_avatar.dart';

class AuthorChangeDialog extends StatelessWidget {
  final List<Author> authorOptions;

  const AuthorChangeDialog({Key? key, this.authorOptions = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign payer'),
      content: Container(
        width: 200,
        child: ListView.builder(
          itemCount: this.authorOptions.length,
          itemBuilder: (context, index) {
            final authorOption = this.authorOptions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AuthorAvatar(
                onTap: () => Navigator.pop(context, authorOption),
                author: authorOption,
                withName: true,
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
