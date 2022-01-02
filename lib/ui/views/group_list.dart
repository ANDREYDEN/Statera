import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/group_service.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/custom_stream_builder.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/listItems/group_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/utils/constants.dart';
import 'package:statera/utils/helpers.dart';

class GroupList extends StatefulWidget {
  static const String route = '/';

  const GroupList({Key? key}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  TextEditingController joinGroupCodeController = TextEditingController();

  User? get user => context.select((AuthBloc auth) => auth.state.user);

  @override
  Widget build(BuildContext context) {
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
      onFabPressed: handleCreateGroup,
      child: user == null
          ? Container()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: joinGroupCodeController,
                          decoration: InputDecoration(labelText: "Group code"),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          snackbarCatch(context, () {
                            GroupService.instance
                                .joinGroup(joinGroupCodeController.text, user!);
                            joinGroupCodeController.clear();
                          });
                        },
                        child: Text("Join"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomStreamBuilder<List<Group>>(
                    stream: GroupService.instance.userGroupsStream(user!.uid),
                    builder: (context, groups) {
                      return groups.isEmpty
                          ? ListEmpty(text: "Join or create a group!")
                          : ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                var group = groups[index];
                                return GestureDetector(
                                  onLongPress: () => handleEditGroup(group),
                                  child: GroupListItem(group: group),
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void handleEditGroup(Group group) {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "Edit Group",
        fields: [
          FieldData(
              id: "group_name",
              label: "Group Name",
              initialData: group.name,
              validators: [FieldData.requiredValidator])
        ],
        onSubmit: (values) =>
            context.read<GroupCubit>().updateName(values["group_name"]!),
      ),
    );
  }

  void handleCreateGroup() {
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Group",
        fields: [
          FieldData(
              id: 'group_name',
              label: "Group Name",
              validators: [FieldData.requiredValidator])
        ],
        onSubmit: (values) async {
          var newGroup = Group(name: values["group_name"]!);
          await GroupService.instance.createGroup(newGroup, user!);
        },
      ),
    );
  }
}
