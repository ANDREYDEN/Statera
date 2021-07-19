import 'package:flutter/material.dart';

class OKCancelDialog extends StatelessWidget {
  final String text;

  const OKCancelDialog({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(this.text),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).errorColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text("Yes"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => Theme.of(context).accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
