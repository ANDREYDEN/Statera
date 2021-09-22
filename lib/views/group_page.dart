import 'package:flutter/material.dart';
import 'package:statera/models/group.dart';
import 'package:statera/providers/group_provider.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/views/group_page_view.dart';
import 'package:statera/widgets/page_scaffold.dart';

class GroupPage extends StatelessWidget {
  static const String route = "/group";
  final String? groupId;

  const GroupPage({Key? key, this.groupId}) : super(key: key);

  Widget build(BuildContext context) {
    return StreamBuilder<Group>(
      stream: Firestore.instance.groupStream(this.groupId),
      builder: (context, snap) {
        if (snap.hasError) {
          return PageScaffold(child: Text(snap.error.toString()));
        }
        if (!snap.hasData || snap.connectionState == ConnectionState.waiting) {
          return PageScaffold(
              child: Center(child: CircularProgressIndicator()));
        }

        final Group group = snap.data!;

        return GroupProvider(group: group, child: GroupPageView());
      },
    );
  }
}
