import 'package:flutter/material.dart';
import 'package:statera/ui/expense/dialogs/qr_dialog.dart';
import 'package:statera/ui/group/group_builder.dart';

class GroupQRButton extends StatelessWidget {
  const GroupQRButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(builder: (context, group) {
      return IconButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (_) => QRDialog(data: group.inviteLink),
          );
        },
        icon: Icon(Icons.qr_code_rounded),
      );
    });
  }
}
