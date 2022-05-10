import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class OKCancelDialog extends StatelessWidget {
  final String text;

  const OKCancelDialog({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(this.text),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text("Yes"),
        ),
      ],
    );
  }
}