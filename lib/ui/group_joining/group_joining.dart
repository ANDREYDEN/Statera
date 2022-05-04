import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group_joining/group_joining_actions.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class GroupJoining extends StatelessWidget {
  static String route = '/join';

  final String? code;

  const GroupJoining({Key? key, this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                // TODO: handle custom error state
                builder: (context, group) {
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
                      GroupJoiningActions(code: code, user: user),
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
