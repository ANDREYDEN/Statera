import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/ui/groups/group_list_item.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/protected_elevated_button.dart';
import 'package:statera/utils/utils.dart';
import 'dart:developer' as developer;

class GroupList extends StatefulWidget {
  static const String route = '/';

  const GroupList({Key? key}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  TextEditingController joinGroupCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return PageScaffold(child: Center(child: Text('Unauthorized')));
        }

        final user = authState.user!;

        var groupsCubit = context.read<GroupsCubit>();
        groupsCubit.load(authState.user!.uid);

        return BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, groupsState) {
            if (groupsState is GroupsLoading) {
              return PageScaffold(child: Center(child: Loader()));
            }

            if (groupsState is GroupsError) {
              developer.log('Failed loading groups', error: groupsState.error);

              return PageScaffold(
                child: Center(child: Text(groupsState.error.toString())),
              );
            }

            if (groupsState is GroupsLoaded) {
              final groups = groupsState.groups;
              final groupsCubit = context.read<GroupsCubit>();

              return PageScaffold(
                title: kAppName,
                actions: [
                  IconButton(
                    onPressed: () {
                      snackbarCatch(context, () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      });
                    },
                    icon: Icon(Icons.logout),
                  ),
                ],
                onFabPressed: () => updateOrCreateGroup(groupsCubit, user),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: joinGroupCodeController,
                              decoration:
                                  InputDecoration(labelText: "Group code"),
                            ),
                          ),
                          SizedBox(width: 8),
                          ProtectedElevatedButton(
                            onPressed: () {
                              snackbarCatch(context, () {
                                groupsCubit.joinGroup(
                                    joinGroupCodeController.text, user);
                                joinGroupCodeController.clear();
                              });
                            },
                            child: Text("Join"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 16,
                      child: Visibility(
                        visible: groupsState is GroupsProcessing,
                        child: Loader(),
                      ),
                    ),
                    Expanded(
                      child: groups.isEmpty
                          ? ListEmpty(text: "Join or create a group!")
                          : ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                var group = groups[index];
                                return GestureDetector(
                                  onLongPress: () => updateOrCreateGroup(
                                    groupsCubit,
                                    user,
                                    group: group,
                                  ),
                                  child: GroupListItem(group: group),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            }

            return Container();
          },
        );
      },
    );
  }

  updateOrCreateGroup(GroupsCubit groupsCubit, User creator, {Group? group}) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'New Group',
        fields: [
          FieldData(
            id: 'group_name',
            label: 'Group Name',
            validators: [FieldData.requiredValidator],
            initialData: group?.name,
          ),
          FieldData(
            id: 'group_currency',
            label: 'Group Currency',
            initialData: group?.currencySign ?? Group.kdefaultCurrencySign,
            validators: [FieldData.requiredValidator],
            formatters: [SingleCharacterTextInputFormatter()],
            isAdvanced: true,
          )
        ],
        onSubmit: (values) async {
          var groupToModify = group ?? new Group.fake();
          final wasModified = groupToModify.name != values['group_name']! ||
              groupToModify.currencySign != values['group_currency'];

          if (!wasModified) return;

          groupToModify.name = values['group_name']!;
          groupToModify.currencySign = values['group_currency'];
          if (group == null) {
            groupsCubit.addGroup(groupToModify, creator);
          } else {
            groupsCubit.updateGroup(groupToModify);
          }
        },
      ),
    );
  }
}
