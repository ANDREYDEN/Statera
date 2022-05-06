import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/ui/widgets/dialogs/ok_cancel_dialog.dart';
import 'package:statera/ui/group/home/owing_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';

class GroupHome extends StatelessWidget {
  const GroupHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var groupCubit = context.read<GroupCubit>();
    var user = context.select((AuthBloc authBloc) => authBloc.state.user);

    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Your Owings',
          style: Theme.of(context).textTheme.headline6,
        ),
        if (user != null)
          Flexible(
            child: StreamProvider<Map<Author, double>>(
              initialData: {},
              create: (context) =>
                  GroupService.instance.getOwingsForUserInGroup(
                user.uid,
                groupCubit.loadedState.group.id,
              ),
              child: Consumer<Map<Author, double>>(
                builder: (_, owings, __) => owings.isEmpty
                    ? ListEmpty(text: 'Nobody here except you...')
                    : ListView.builder(
                        itemCount: owings.length,
                        itemBuilder: (context, index) {
                          var payer = owings.keys.elementAt(index);
                          return OwingListItem(
                            member: payer,
                            owing: owings[payer]!,
                          );
                        },
                      ),
              ),
            ),
          ),
        if (user != null)
          TextButton(
            onPressed: () async {
              var decision = await showDialog<bool>(
                context: context,
                builder: (context) => OKCancelDialog(
                  text: "Are you sure you want to leave the group?",
                ),
              );
              if (decision!) {
                groupCubit.removeUser(user.uid);
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
