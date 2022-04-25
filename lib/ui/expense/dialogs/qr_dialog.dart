import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRDialog extends StatelessWidget {
  final String? data;

  const QRDialog({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 400,
        child: data == null
            ? Text("Unable to render invite QR code")
            : QrImage(
                data: data!,
                foregroundColor: Theme.of(context).textTheme.bodyText1!.color,
              ),
      ),
    );
  }
}
