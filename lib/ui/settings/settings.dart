import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/ui/widgets/author_avatar.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class Settings extends StatelessWidget {
  static const String route = '/settings';

  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: AuthorAvatar(
                author: Author.fromUser(authBloc.user),
                width: 200,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                authBloc.add(LogoutRequested());
              },
              child: Text('Log Out'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                var decision = await showDialog<bool>(
                  context: context,
                  builder: (context) => OKCancelDialog(
                    text: 'Are you sure you want to delete your account?',
                  ),
                );
                if (decision!) {
                  authBloc.add(AccountDeletionRequested());
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Delete Account',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
