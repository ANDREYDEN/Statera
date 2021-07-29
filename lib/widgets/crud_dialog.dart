import 'package:flutter/material.dart';

class FieldData {
  String id;
  String label;
  late TextEditingController controller;
  TextInputType inputType;

  FieldData(
      {required this.id,
      required this.label,
      TextEditingController? controller,
      this.inputType = TextInputType.name}) {
    this.controller = controller ?? TextEditingController();
  }
}

class CRUDDialog extends StatefulWidget {
  final String title;
  final Future Function(Map<String, String>) onSubmit;
  final List<FieldData> fields;

  const CRUDDialog({
    Key? key,
    required this.title,
    required this.onSubmit,
    required this.fields,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  bool _dirty = false;

  @override
  void initState() {
    widget.fields.forEach((field) {
      field.controller.addListener(() => setState(() {
            this._dirty = true;
          }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(children: [...textFields]),
      actions: [ElevatedButton(onPressed: submit, child: Text("Save"))],
    );
  }

  Iterable<Widget> get textFields sync* {
    var focusNodes = widget.fields.map((field) => FocusNode(debugLabel: field.id)).toList();
    for (var i = 0; i < widget.fields.length; i++) {
      var field = widget.fields[i];
      yield TextField(
        autofocus: i == 0,
        focusNode: focusNodes[i],
        controller: field.controller,
        keyboardType: field.inputType,
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.controller.text.isEmpty && this._dirty
              ? "Can't be empty"
              : null,
        ),
        onSubmitted: (_) {
          if (i == widget.fields.length - 1) {
            submit();
          } else {
            focusNodes[i+1].requestFocus();
          }
        }
      );
    }
  }

  submit() async {
    if (widget.fields.any((field) => field.controller.text.isEmpty)) {
      setState(() {
        this._dirty = true;
      });
      return;
    }

    await widget.onSubmit(
      Map.fromEntries(widget.fields.map(
        (field) => MapEntry(
          field.id,
          field.controller.text,
        ),
      )),
    );

    widget.fields.forEach((field) {
      field.controller.clear();
    });
    Navigator.of(context).pop();
  }
}
