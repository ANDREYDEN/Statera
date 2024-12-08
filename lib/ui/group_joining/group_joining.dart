import 'package:flutter/material.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/group_joining/error_state.dart';
import 'package:statera/ui/group_joining/group_joining_actions.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class GroupJoining extends StatelessWidget {
  static const String name = 'GroupJoining';
  final String? code;

  const GroupJoining({Key? key, this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Center(
        child: Container(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GroupBuilder(
                builder: (context, group) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You are about to join',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        group.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      GroupJoiningActions(code: code),
                    ],
                  );
                },
                errorBuilder: (context, errorState) =>
                    GroupJoiningErrorState(error: errorState.error.toString()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
