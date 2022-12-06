import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/ui/authentication/user_builder.dart';

class UsernameSetting extends StatefulWidget {
  const UsernameSetting({Key? key}) : super(key: key);

  @override
  State<UsernameSetting> createState() => _UsernameSettingState();
}

class _UsernameSettingState extends State<UsernameSetting> {
  late TextEditingController _usernameController;
  String? _displayNameErrorText = null;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();

    return UserBuilder(
      builder: (context, user) {
        _usernameController = TextEditingController(text: user.name);
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: user.name,
                decoration: InputDecoration(
                  label: Text('Display Name'),
                  errorText: _displayNameErrorText,
                ),
                onChanged: (value) {
                  setState(() {
                    _displayNameErrorText =
                        value == '' ? 'Can not be empty' : null;
                  });
                },
              ),
            ),
            if (_usernameController.text != user.name) ...[
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

                  userCubit.updateName(user.uid, _usernameController.text);
                },
              )
            ]
          ],
        );
      },
    );
  }
}
