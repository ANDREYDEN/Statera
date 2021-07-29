import 'package:flutter/material.dart';

class CRUDDialog extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String label;
  final Future Function() action;

  const CRUDDialog({
    Key? key,
    required this.controller,
    required this.title,
    required this.action,
    required this.label,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  bool _dirty = false;

  @override
  void initState() {
    widget.controller.addListener(() => setState(() {
          this._dirty = true;
        }));
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
              labelText: widget.label,
              errorText: widget.controller.text.isEmpty && this._dirty
                  ? "Can't be empty"
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (widget.controller.text.isEmpty) {
              setState(() {
                this._dirty = true;
              });
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
