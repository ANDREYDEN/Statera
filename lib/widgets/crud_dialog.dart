import 'package:flutter/material.dart';

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
  @override
  void initState() {
    widget.controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        children: [
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: "Group name",
              errorText:
                  widget.controller.text.isEmpty ? "Can't be empty" : null,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (widget.controller.text.isEmpty) {
              return;
            }

            await widget.action();
            widget.controller.clear();
            Navigator.of(context).pop();
          },
          child: Text("Save"),
        )
      ],
    );
  }
}
