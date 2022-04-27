import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are about to join <Some Group>',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Join'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor,
                        ),
                      ),
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
          ),
        ),
      ),
    );
  }
}
