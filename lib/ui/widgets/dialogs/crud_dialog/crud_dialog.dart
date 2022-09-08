import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_elevated_button.dart';

part 'field_data.dart';

class CRUDDialog extends StatefulWidget {
  final String title;
  final FutureOr<void> Function(Map<String, String>) onSubmit;
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
  bool _showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: 200,
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [...getTextFields((f) => !f.isAdvanced)],
            ),
            if (widget.fields.any((f) => f.isAdvanced))
              GestureDetector(
                onTap: () => setState(() {
                  _showAdvanced = !_showAdvanced;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text('Advanced'),
                      Icon(
                        _showAdvanced
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),
            Visibility(
              visible: _showAdvanced,
              child: Column(children: [...getTextFields((f) => f.isAdvanced)]),
            ),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        ProtectedElevatedButton(
          onPressed: () => submit(closeAfterSubmit: widget.closeAfterSubmit),
          child: Text('Save'),
        ),
        if (widget.allowAddAnother)
          TextButton(onPressed: submit, child: Text('Save & add another'))
      ],
    );
  }

  Iterable<Widget> getTextFields(bool Function(FieldData) criteria) sync* {
    final selectedFields = widget.fields.where(criteria).toList();
    for (var i = 0; i < selectedFields.length; i++) {
      var field = selectedFields[i];
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
          var isLastField = i == selectedFields.length - 1;
          if (isLastField) {
            submit(closeAfterSubmit: widget.closeAfterSubmit);
          } else {
            selectedFields[i + 1].focusNode.requestFocus();
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
