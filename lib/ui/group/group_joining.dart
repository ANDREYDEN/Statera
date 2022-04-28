import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/groups/group_list.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/protected_elevated_button.dart';

import 'group_builder.dart';
import 'group_page.dart';

class GroupJoining extends StatelessWidget {
  static String route = '/join';

  final String? groupId;
  final String? code;

  const GroupJoining({Key? key, this.groupId, this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (groupId == null) {
      return PageScaffold(child: Text('Invalid group reference'));
    }

    var user = context.select((AuthBloc authBloc) => authBloc.state.user);

    if (user == null) {
      return PageScaffold(child: Text("Unauthorized"));
    }

    return PageScaffold(
      child: Center(
        child: Container(
          width: 400,
          child: Card(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GroupBuilder(
                builder: (context, group) {
                  String? error;

                  if (group.userExists(user.uid)) {
                    error = 'You are already a member of this group';
                  } else if (group.code != code) {
                    error = 'Invalid group invitation. Make sure you have copied it properly.';
                  }

                  if (error != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            GroupList.route,
                          ),
                          child: Text('Back'),
                        )
                      ],
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You are about to join',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        group.name,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ProtectedElevatedButton(
                              onPressed: () async {
                                group.addUser(user);
                                await GroupService.instance.saveGroup(group);
                                Navigator.pushReplacementNamed(
                                    context, '${GroupPage.route}${group.id}');
                              },
                              child: Text('Join'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, GroupList.route);
                              },
                              child: Text('Cancel'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).errorColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
