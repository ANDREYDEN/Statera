import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/utils/helpers.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/widgets/custom_stream_builder.dart';
import 'package:statera/widgets/listItems/group_list_item.dart';
import 'package:statera/widgets/page_scaffold.dart';

class GroupList extends StatefulWidget {
  static const String route = '/';

  const GroupList({Key? key}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  TextEditingController newGroupNameController = TextEditingController();
  TextEditingController joinGroupCodeController = TextEditingController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);
  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth.instance.currentUserStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text(userSnapshot.error.toString());
        }
        final loading = userSnapshot.connectionState == ConnectionState.waiting;

        User? user = userSnapshot.data;

        return PageScaffold(
          title: 'Statera',
          actions: user == null
              ? null
              : [
                  ElevatedButton(
                    onPressed: () {
                      snackbarCatch(context, () {
                        Auth.instance.signOut();
                      });
                    },
                    child: Text("Sign Out"),
                  ),
                ],
          onFabPressed: user == null ? null : handleNewGroup,
          child: loading
              ? Text("Loading...")
              : user == null
                  ? this.noUserView
                  : Column(
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
                                    authVm.joinGroup(
                                      joinGroupCodeController.text,
                                    );
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
                            stream: Firestore.instance
                                .userGroupsStream(authVm.user.uid),
                            builder: (context, groups) {
                              return groups.isEmpty
                                  ? Text("You don't have any groups yet...")
                                  : ListView.builder(
                                      itemCount: groups.length,
                                      itemBuilder: (context, index) {
                                        return GroupListItem(
                                          group: groups[index],
                                        );
                                      },
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget get noUserView => ElevatedButton(
        onPressed: () async {
          snackbarCatch(context, () async {
            await Auth.instance.signInWithGoogle();
          });
        },
        child: Text("Log In with Google"),
      );

  void handleNewGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Group"),
        content: Column(
          children: [
            TextField(
              controller: newGroupNameController,
              decoration: InputDecoration(labelText: "Group name"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              var newGroup = Group(
                name: newGroupNameController.text,
              );
              await authVm.createGroup(newGroup);
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }
}
