import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/authentication/user_builder.dart';
import 'package:statera/ui/widgets/buttons/danger_button.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({Key? key}) : super(key: key);

  void _handleDeleteAccount(BuildContext context, CustomUser user) {
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (context) => DangerDialog(
        title: 'You are about to DELETE you account',
        valueName: 'username',
        value: user.name,
        onConfirm: () {
          authBloc.add(AccountDeletionRequested());
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserBuilder(
      builder: (context, user) {
        return ListTile(
          title: Text('Delete your Account'),
          subtitle: Text(
            'Deleting your account will remove your user data from the system. There is no way to undo this action.',
          ),
          trailing: DangerButton(
            text: 'Delete Account',
            onPressed: () => _handleDeleteAccount(context, user),
          ),
        );
      },
    );
  }
}
