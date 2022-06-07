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

    return GroupBuilder(builder: (context, group) {
      currencyController.text = group.currencySign;

      return Container(
        width: 400,
        child: Column(
          children: [
            TextField(
              controller: currencyController,
              decoration: InputDecoration(labelText: 'Currency Sign'),
              onSubmitted: (value) {
                groupCubit.updateCurrencySign(value);
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
      );
    });
  }
}
