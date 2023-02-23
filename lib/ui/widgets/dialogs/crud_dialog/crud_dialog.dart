import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/advanced_dropdown.dart';

part 'field_data.dart';

class CRUDDialog extends StatefulWidget {
  final String title;
  final FutureOr<void> Function(Map<String, dynamic>) onSubmit;
  final List<FieldData> fields;
  final bool closeAfterSubmit;
  final bool allowAddAnother;

  const CRUDDialog({
    Key? key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.closeAfterSubmit = true,
    this.allowAddAnother = false,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  bool _dirty = false;
  bool _showAdvanced = false;
  late bool _addAnother = true;

  @override
  Widget build(BuildContext context) {
    final isWide = context.read<LayoutState>().isWide;

    final wideScreenActions = [
      CancelButton(),
      ProtectedButton(
        onPressed: () => submit(closeAfterSubmit: widget.closeAfterSubmit),
        child: Text('Save'),
      ),
      if (widget.allowAddAnother)
        ProtectedButton(onPressed: submit, child: Text('Save & add another'))
    ];

    final narrowScreenActions = [
      Column(
        children: [
          if (widget.allowAddAnother)
            GestureDetector(
              onTap: () => setState(() {
                _addAnother = !_addAnother;
              }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Add another'),
                  Checkbox(
                    value: _addAnother,
                    onChanged: (_) => setState(() {
                      _addAnother = !_addAnother;
                    }),
                  )
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 8),
              CancelButton(),
              SizedBox(width: 16),
              ProtectedButton(
                onPressed: () => submit(
                    closeAfterSubmit:
                        (!widget.allowAddAnother || !_addAnother) &&
                            widget.closeAfterSubmit),
                child: Text('Save'),
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
    ];

    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: isWide ? 400 : 200,
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [...getFields((f) => !f.isAdvanced)],
            ),
            if (_advancedFieldsPresent)
              AdvancedDropdown(
                onTap: () => setState(() {
                  _showAdvanced = !_showAdvanced;
                }),
                isCollapsed: _showAdvanced,
              ),
            if (_showAdvanced)
              Column(children: [...getFields((f) => f.isAdvanced)]),
          ],
        ),
      ),
      actions: isWide ? wideScreenActions : narrowScreenActions,
    );
  }

  bool get _advancedFieldsPresent => widget.fields.any((f) => f.isAdvanced);

  Iterable<Widget> getFields(bool Function(FieldData) criteria) sync* {
    final selectedFields = widget.fields.where(criteria).toList();
    final fieldValueMap = selectedFields.fold<Map<String, dynamic>>(
      {},
      (acc, cur) => {...acc, cur.id: cur.data},
    );

    for (var i = 0; i < selectedFields.length; i++) {
      var field = selectedFields[i];
      if (field.isVisible != null && !field.isVisible!(fieldValueMap)) continue;
      var isLastField = i == selectedFields.length - 1;
      var isFirstField = i == 0;
      if (field.initialData is String || field.initialData is num) {
        yield ListTile(
          title: TextFormField(
            controller: field.controller,
            autofocus: isFirstField,
            focusNode: field.focusNode,
            keyboardType: field.initialData is String
                ? TextInputType.text
                : field.initialData is double
                    ? TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
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
                field.changeData(text);
              });
            },
            onFieldSubmitted: (_) {
              if (isLastField) {
                submit(closeAfterSubmit: widget.closeAfterSubmit);
              } else {
                selectedFields[i + 1].focusNode.requestFocus();
              }
            },
          ),
        );
      } else if (field.initialData is bool) {
        yield SwitchListTile(
          title: Text(field.label),
          value: field.data,
          autofocus: isFirstField,
          focusNode: field.focusNode,
          onChanged: (newValue) => setState(() {
            this._dirty = true;
            field.changeData(newValue);
          }),
        );
      }
    }
  }

  void submit({bool closeAfterSubmit = false}) async {
    if (widget.fields.any((field) => field.getError().isNotEmpty)) {
      setState(() {
        this._dirty = true;
      });
      return;
    }

    await widget.onSubmit(
      Map.fromEntries(widget.fields.map(
        (field) => MapEntry(field.id, field.data),
      )),
    );

    if (closeAfterSubmit) {
      Navigator.of(context).pop();
    } else {
      widget.fields.first.focusNode.requestFocus();
    }

    widget.fields.forEach((field) {
      field.reset();
    });
  }
}
