import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/share_button.dart';

class QRDialog extends StatelessWidget {
  final String? data;

  const QRDialog({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return AlertDialog(content: Text('Unable to generate invite'));
    }

    return AlertDialog(
      title: Text('Invite people to this group'),
      content: SizedBox(
        width: 200,
        child: QrImage(
          data: data!,
          foregroundColor: Theme.of(context).textTheme.bodyText1!.color,
        ),
      ),
      actions: [
        Row(
          children: [
            const Expanded(child: const CancelButton()),
            Expanded(
              child: ShareButton(
                data: data!,
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
  }
}
