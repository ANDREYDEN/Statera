import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Column(
      children: [
        CircleAvatar(),
        ElevatedButton(
          onPressed: () {
            authBloc.add(LogoutRequested());
          },
          child: Text('Log Out'),
        ),
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
            'Leave group',
            style: TextStyle(
              color: Theme.of(context).errorColor,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}
