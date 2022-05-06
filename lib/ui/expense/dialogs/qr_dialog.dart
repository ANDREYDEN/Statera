import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:statera/ui/widgets/cancel_button.dart';

class QRDialog extends StatelessWidget {
  final String? data;

  const QRDialog({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return AlertDialog(content: Text("Unable to generate invite"));
    }

    return AlertDialog(
      title: Text('Invite people to this group'),
      content: SizedBox(
        width: 400,
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
              child: kIsWeb
                  ? ElevatedButton(
                      onPressed: () async {
                        ClipboardData clipData = ClipboardData(text: data);
                        await Clipboard.setData(clipData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invite link copied to clipboard'),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.copy, size: 30),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Share.share(data!);
                      },
                      child: const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.share, size: 30),
                      ),
                    ),
            ),
          ],
        )
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
