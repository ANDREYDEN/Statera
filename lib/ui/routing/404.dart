import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

import '../groups/group_list.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404 - nothing interesting here'),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popAndPushNamed(GroupList.route),
              child: Text('Back home'),
            )
          ],
        ),
      ),
    );
  }
}
