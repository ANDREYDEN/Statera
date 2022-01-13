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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Invite people with the code:",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, groupState) {
                if (groupState is GroupLoading) {
                  return Center(child: Loader());
                }

                if (groupState is GroupError) {
                  return Text(groupState.error.toString());
                }

                if (groupState is GroupLoaded) {
                  return TextButton(
                    onPressed: () async {
                      ClipboardData data = ClipboardData(
                        text: groupState.group.code.toString(),
                      );
                      await Clipboard.setData(data);
                    },
                    child: Row(
                      children: [
                        Text(
                          groupState.group.code.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.copy),
                      ],
                    ),
                  );
                }
                return Text('Something went wrong');
              })
            ],
          ),
        ),
        Divider(thickness: 1),
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
