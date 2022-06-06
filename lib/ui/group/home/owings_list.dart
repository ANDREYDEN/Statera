import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group/home/owing_list_item.dart';
import 'package:statera/ui/widgets/dialogs/ok_cancel_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';

class OwingsList extends StatelessWidget {
  const OwingsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var groupCubit = context.read<GroupCubit>();
    var authBloc = context.read<AuthBloc>();

    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Your Owings',
          style: Theme.of(context).textTheme.headline6,
        ),
        Flexible(
          child: GroupBuilder(
            builder: (context, group) {
              final owings = group.extendedBalance(authBloc.uid);
              return owings.isEmpty
                  ? ListEmpty(text: 'Start by inviting people to your group...')
                  : ListView.builder(
                      itemCount: owings.length,
                      itemBuilder: (context, index) {
                        var payer = owings.keys.elementAt(index);
                        return OwingListItem(
                          member: payer,
                          owing: owings[payer]!,
                        );
                      },
                    );
            },
          ),
        ),
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
    );
  }
}
