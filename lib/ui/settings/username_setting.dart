import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';

class UsernameSetting extends StatefulWidget {
  const UsernameSetting({Key? key}) : super(key: key);

  @override
  State<UsernameSetting> createState() => _UsernameSettingState();
}

class _UsernameSettingState extends State<UsernameSetting> {
  late final String _initialUsername;
  late TextEditingController _usernameController;
  String? _displayNameErrorText = null;

  AuthBloc get authBloc => context.read<AuthBloc>();

  @override
  void initState() {
    _initialUsername = authBloc.user.displayName ?? 'anonymous';
    _usernameController = TextEditingController(text: _initialUsername);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        if (_usernameController.text != _initialUsername) ...[
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
}
