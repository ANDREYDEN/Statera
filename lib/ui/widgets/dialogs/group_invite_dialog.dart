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
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: QrImageView(
                        data: inviteLink,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.circle,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                    Flexible(
                      child: FilledButton.tonal(
                        onPressed: onGenerate,
                        child: Text('Re-generate invite'),
                      ),
                    )
                  ],
                ),
          actions: [
            const CancelButton(),
            if (inviteLink != null)
              ShareButton(
                data: inviteLink,
                copyMessage: 'Invite link copied to clipboard',
                mobileIcon: Icons.copy,
                afterShare: () => Navigator.pop(context),
              ),
          ],
        );
      },
    );
  }
}
