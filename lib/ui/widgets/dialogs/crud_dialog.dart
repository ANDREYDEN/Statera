import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:statera/ui/widgets/protected_elevated_button.dart';

class FieldData {
  String id;
  String label;
  late TextEditingController controller;
  late FocusNode focusNode;
  TextInputType inputType;
  dynamic initialData;
  List<String Function(String)> validators;
  List<TextInputFormatter> formatters;

  FieldData({
    required this.id,
    required this.label,
    this.initialData,
    TextEditingController? controller,
    this.validators = const [],
    this.formatters = const [],
    this.inputType = TextInputType.name,
  }) {
    this.controller = controller ?? TextEditingController();
    resetController();
    this.focusNode = FocusNode(debugLabel: this.id);
  }

  static String requiredValidator(String text) =>
      text.isEmpty ? "Can't be empty" : "";
  static String doubleValidator(String text) =>
      double.tryParse(text) == null ? "Must be a number" : "";
  static String intValidator(String text) =>
      int.tryParse(text) == null ? "Must be a whole number" : "";

  String getError() {
    for (final formatter in this.validators) {
      var error = formatter(this.controller.text);
      if (error.isNotEmpty) return error;
    }
    return '';
  }

  void resetController() {
    controller.text = initialData?.toString() ?? '';
  }
}

class CRUDDialog extends StatefulWidget {
  final String title;
  final Future Function(Map<String, String>) onSubmit;
  final List<FieldData> fields;
  final bool closeAfterSubmit;
  final bool allowAddAnother;

  const CRUDDialog({
    Key? key,
    required this.title,
    required this.onSubmit,
    required this.fields,
    this.closeAfterSubmit = true,
    this.allowAddAnother = false,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(children: [...textFields]),
      actions: [
        ProtectedElevatedButton(
          onPressed: () => submit(closeAfterSubmit: widget.closeAfterSubmit),
          child: Text("Save"),
        ),
        if (widget.allowAddAnother)
          TextButton(onPressed: submit, child: Text('Save & add another'))
      ],
    );
  }

  Iterable<Widget> get textFields sync* {
    for (var i = 0; i < widget.fields.length; i++) {
      var field = widget.fields[i];
      yield TextField(
        autofocus: i == 0,
        focusNode: field.focusNode,
        controller: field.controller,
        keyboardType: field.inputType,
        inputFormatters: field.formatters,
        decoration: InputDecoration(
          labelText: field.label,
          errorText: this._dirty && field.getError().isNotEmpty
              ? field.getError()
              : null,
        ),
        onChanged: (text) {
          setState(() {
            this._dirty = true;
          });
        },
        onSubmitted: (_) {
          var isLastField = i == widget.fields.length - 1;
          if (isLastField) {
            submit(closeAfterSubmit: widget.closeAfterSubmit);
          } else {
            widget.fields[i + 1].focusNode.requestFocus();
          }
        },
      );
    }
  }

  submit({bool closeAfterSubmit = false}) async {
    if (widget.fields.any((field) => field.getError().isNotEmpty)) {
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

    if (closeAfterSubmit) {
      Navigator.of(context).pop();
    } else {
      widget.fields.first.focusNode.requestFocus();
    }

    widget.fields.forEach((field) {
      field.resetController();
    });
  }
}
