import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

import 'group_builder.dart';

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

    return PageScaffold(
      child: Center(
        child: Container(
          width: 400,
          child: Card(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GroupBuilder(builder: (context, group) {
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
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Join'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
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
              }),
            ),
          ),
        ),
      ),
    );
  }
}
