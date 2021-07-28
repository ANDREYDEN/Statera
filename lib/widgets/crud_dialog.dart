import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CRUDDialog extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final Future Function() action;

  const CRUDDialog({
    Key? key,
    required this.controller,
    required this.title,
    required this.action,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  String inputText = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                inputText = value;
              });
            },
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: "Group name",
              errorText: inputText == "" ? "Can't be empty" : null,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (inputText == '') {
              return;
            }

            await widget.action();
            Navigator.of(context).pop();
          },
          child: Text("Save"),
        )
      ],
    );
  }
}
