import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';

class UsernameSetting extends StatefulWidget {
  const UsernameSetting({Key? key}) : super(key: key);

  @override
  State<UsernameSetting> createState() => _UsernameSettingState();
}

class _UsernameSettingState extends State<UsernameSetting> {
  late TextEditingController _usernameController;
  String? _displayNameErrorText = null;

  AuthBloc get authBloc => context.read<AuthBloc>();

  @override
  void initState() {
    _usernameController =
        TextEditingController(text: authBloc.user.displayName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  label: Text('Display Name'),
                  errorText: _displayNameErrorText,
                ),
                onChanged: (value) {
                  setState(() {
                    _displayNameErrorText = value == '' ? 'Can not be empty' : null;
                  });
                },
              ),
            ),
            if (_usernameController.text != authState.user?.displayName) ...[
              SizedBox(width: 4),
              ElevatedButton(
                child: Icon(Icons.check_rounded),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(0),
                ),
                onPressed: () {
                  if (_usernameController.text == '') return;

                  authBloc.add(UserDataUpdated(name: _usernameController.text));
                },
              )
            ]
          ],
        );
      }
    );
  }
}
