import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';

class OKCancelDialog extends StatelessWidget {
  final String text;
  final String? title;

  const OKCancelDialog({
    Key? key,
    required this.text,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title == null ? null : Text(title!),
      content: DialogWidth(child: Text(this.text)),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}
