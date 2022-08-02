import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:statera/ui/group/group_builder.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/share_button.dart';

class GroupInviteDialog extends StatelessWidget {
  final void Function() onGenerate;

  const GroupInviteDialog({
    Key? key,
    required this.onGenerate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupBuilder(
      builder: (context, group) {
        final inviteLink = group.inviteLink;
        return AlertDialog(
          title: Text('Invite people to this group'),
          content: inviteLink == null
              ? ElevatedButton(
                  onPressed: onGenerate,
                  child: Text('Generate invite'),
                )
              : SizedBox(
                  width: 200,
                  child: QrImage(
                    data: inviteLink,
                    foregroundColor:
                        Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
          actions: [
            Row(
              children: [
                const Expanded(child: const CancelButton()),
                if (inviteLink != null)
                  Expanded(
                    child: ShareButton(
                      data: inviteLink,
                      copyMessage: 'Invite link copied to clipboard',
                      iconSize: 30,
                      afterShare: () => Navigator.pop(context),
                    ),
                  ),
              ],
            )
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}
