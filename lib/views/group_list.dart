import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/group.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/widgets/listItems/group_list_item.dart';
import 'package:statera/widgets/page_scaffold.dart';

class GroupList extends StatelessWidget {
  static const String route = '/';

  const GroupList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthenticationViewModel>(context);
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
                      Auth.instance.signOut();
                    },
                    child: Text("Sign Out"),
                  ),
                ],
          child: loading
              ? Text("Loading...")
              : user == null
                  ? this.noUserView
                  : StreamBuilder<List<Group>>(
                      stream:
                          Firestore.instance.userGroupsStream(authVm.user.uid),
                      builder: (context, snap) {
                        if (!snap.hasData ||
                            snap.connectionState == ConnectionState.waiting) {
                          return Text("Loading...");
                        }

                        var groups = snap.data!;

                        return ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            return GroupListItem(group: groups[index]);
                          },
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget get noUserView => ElevatedButton(
        onPressed: () {
          Auth.instance.signInWithGoogle();
        },
        child: Text("Log In with Google"),
      );
}
