import 'package:flutter/material.dart';
import 'package:statera/ui/group/group_builder.dart';

class GroupTitle extends StatelessWidget {
  const GroupTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) => SelectableText(
        group.name,
        style: TextStyle(overflow: TextOverflow.ellipsis),
      ),
      loadingWidget: Text('...'),
    );
  }
}
