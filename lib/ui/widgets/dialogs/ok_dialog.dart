import 'package:flutter/material.dart';

class OKDialog extends StatelessWidget {
  final String text;
  final String? title;

  const OKDialog({
    Key? key,
    required this.text,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title == null ? null : Text(title!),
      content: Text(this.text),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text('Ok'),
        ),
      ],
    );
  }
}
