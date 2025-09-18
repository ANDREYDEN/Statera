import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

import '../groups/group_list_page.dart';

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
              onPressed: () => context.goNamed(GroupListPage.name),
              child: Text('Back home'),
            )
          ],
        ),
      ),
    );
  }
}
