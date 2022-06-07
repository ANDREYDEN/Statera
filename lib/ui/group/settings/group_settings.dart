import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/dialogs/dialogs.dart';

class GroupSettings extends StatelessWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.read<GroupCubit>();
    final authBloc = context.read<AuthBloc>();
    final currencyController = TextEditingController();
    final nameController = TextEditingController();

    return GroupBuilder(builder: (context, group) {
      currencyController.text = group.currencySign;
      nameController.text = group.name;

      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width / 3,
          child: Column(
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headline6,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                onSubmitted: (value) {
                  groupCubit.update((group) {
                    group.name = value;
                  });
                },
              ),
              TextField(
                controller: currencyController,
                decoration: InputDecoration(labelText: 'Currency Sign'),
                onSubmitted: (value) {
                  groupCubit.update((group) {
                    group.currencySign = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  var decision = await showDialog<bool>(
                    context: context,
                    builder: (context) => OKCancelDialog(
                      text: "Are you sure you want to leave the group?",
                    ),
                  );
                  if (decision!) {
                    groupCubit.removeUser(authBloc.uid);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Leave group",
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
    });
  }
}
