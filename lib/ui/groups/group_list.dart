import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/groups/group_list_item.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/utils.dart';

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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.status == AuthStatus.authenticated) {
          var groupsCubit = context.read<GroupsCubit>();
          groupsCubit.load(authState.user!.uid);
        }
      },
      builder: (context, authState) {
        if (authState.status == AuthStatus.unauthenticated) {
          return PageScaffold(child: Center(child: Text('Unauthorized')));
        }

        final user = authState.user!;

        return BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, groupsState) {
            if (groupsState is GroupsLoading) {
              return PageScaffold(child: Center(child: Loader()));
            }

            if (groupsState is GroupsError) {
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
                onFabPressed: () => _handleNewGroupClick(groupsCubit, user),
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
                          ElevatedButton(
                            onPressed: () {
                              snackbarCatch(context, () {
                                GroupService.instance.joinGroup(
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
                                  onLongPress: () =>
                                      _handleGroupLongPress(groupsCubit, group),
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

  void _handleGroupLongPress(GroupsCubit groupsCubit, Group group) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Group",
        fields: [
          FieldData(
            id: "group_name",
            label: "Group Name",
            initialData: group.name,
            validators: [FieldData.requiredValidator],
          )
        ],
        onSubmit: (values) {
          group.name = values['group_name']!;
          groupsCubit.updateGroup(group);
        },
      ),
    );
  }

  void _handleNewGroupClick(GroupsCubit groupsCubit, User creator) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: 'New Group',
        fields: [
          FieldData(
            id: 'group_name',
            label: 'Group Name',
            validators: [FieldData.requiredValidator],
          ),
          FieldData(
            id: 'group_currency',
            label: 'Group Currency',
            initialData: Group.kdefaultCurrencySign,
            formatters: [SingleCharacterTextInputFormatter()],
            isAdvanced: true,
          )
        ],
        onSubmit: (values) async {
          var newGroup = Group(
            name: values['group_name']!,
            currencySign: values['group_currency'],
          );
          groupsCubit.addGroup(newGroup, creator);
        },
      ),
    );
  }
}
