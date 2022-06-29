import 'package:flutter/material.dart';
import 'package:statera/data/services/dynamic_link_service.dart';
import 'package:statera/ui/expense/dialogs/qr_dialog.dart';
import 'package:statera/ui/group/group_builder.dart';

class GroupQRButton extends StatelessWidget {
  const GroupQRButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(builder: (context, group) {
      return IconButton(
        onPressed: () async {
          final dynamicLink = DynamicLinkService.generateDynamicLink(
            path: "group/${group.id}/join/${group.code}",
          );

          showDialog(
            context: context,
            builder: (_) => QRDialog(data: dynamicLink.toString()),
          );
        },
        icon: Icon(Icons.qr_code_rounded),
      );
    });
  }
}
