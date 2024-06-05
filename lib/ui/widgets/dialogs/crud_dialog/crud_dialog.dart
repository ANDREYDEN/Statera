import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/advanced_dropdown.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/narrow_screen_actions.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';

part 'field_data.dart';

class CRUDDialog extends StatefulWidget {
  final String title;
  final FutureOr<void> Function(Map<String, dynamic>) onSubmit;
  late final List<ButtonSegment<String>> segments;
  late final Map<String, List<FieldData>> fieldsMap;
  final bool closeAfterSubmit;
  final bool allowAddAnother;
  late final bool segmentSelectionEnabled;
  final String? initialSelection;

  CRUDDialog({
    Key? key,
    required this.title,
    required List<FieldData> fields,
    required this.onSubmit,
    this.closeAfterSubmit = true,
    this.allowAddAnother = false,
    this.initialSelection,
  }) : super(key: key) {
    this.fieldsMap = {'default': fields};
    this.segments = [];
    this.segmentSelectionEnabled = true;
  }

  CRUDDialog.segmented({
    Key? key,
    required this.title,
    required this.segments,
    required this.fieldsMap,
    required this.onSubmit,
    this.closeAfterSubmit = true,
    this.allowAddAnother = false,
    this.segmentSelectionEnabled = true,
    this.initialSelection,
  }) : super(key: key);

  @override
  _CRUDDialogState createState() => _CRUDDialogState();
}

class _CRUDDialogState extends State<CRUDDialog> {
  bool _dirty = false;
  bool _showAdvanced = false;
  bool _addAnother = true;

  late String _selectedValue;

  List<FieldData> get _fields => widget.fieldsMap[_selectedValue]!;

  @override
  void initState() {
    _selectedValue = widget.initialSelection ??
        widget.segments.firstOrNull?.value ??
        'default';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: DialogWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.segments.isNotEmpty)
              SegmentedButton(
                segments: widget.segments,
                selected: {_selectedValue},
                onSelectionChanged: widget.segmentSelectionEnabled
                    ? _handleSegmentSelection
                    : null,
              ),
            ListView(
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [..._getFields((f) => !f.isAdvanced)],
                ),
                if (_advancedFieldsPresent)
                  AdvancedDropdown(
                    onTap: () => setState(() {
                      _showAdvanced = !_showAdvanced;
                    }),
                    isCollapsed: _showAdvanced,
                  ),
                if (_showAdvanced)
                  Column(children: [..._getFields((f) => f.isAdvanced)]),
              ],
            ),
          ],
        ),
      ),
      actions: getActions(context),
    );
  }

  List<Widget> getActions(BuildContext context) {
    final isWide = context.read<LayoutState>().isWide;

    if (isWide) {
      return [
        CancelButton(),
        ProtectedButton(
          onPressed: () => submit(closeAfterSubmit: widget.closeAfterSubmit),
          child: Text('Save'),
        ),
        if (widget.allowAddAnother)
          ProtectedButton(onPressed: submit, child: Text('Save & add another'))
      ];
    }

    return [
      NarrowScreenActions(
        allowAddAnother: widget.allowAddAnother,
        onAddAnother: () => setState(() {
          _addAnother = !_addAnother;
        }),
        onSave: () => submit(
            closeAfterSubmit: (!widget.allowAddAnother || !_addAnother) &&
                widget.closeAfterSubmit),
        addAnother: _addAnother,
      )
    ];
  }

  bool get _advancedFieldsPresent => _fields.any((f) => f.isAdvanced);

  void _handleSegmentSelection(Set<String> values) {
    setState(() {
      _selectedValue = values.single;
    });
    _focusOnFirstField();
  }

  Iterable<Widget> _getFields(bool Function(FieldData) criteria) sync* {
    final selectedFields = _fields.where(criteria).toList();
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
        yield TextFormField(
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

  Future submit({bool closeAfterSubmit = false}) async {
    if (_fields.any((field) => field.getError().isNotEmpty)) {
      setState(() {
        this._dirty = true;
      });
      return;
    }

    await widget.onSubmit(
      Map.fromEntries(_fields.map(
        (field) => MapEntry(field.id, field.data),
      )),
    );

    if (closeAfterSubmit) {
      Navigator.of(context).pop();
    } else {
      _focusOnFirstField();
    }

    _fields.forEach((field) {
      field.reset();
    });
  }

  void _focusOnFirstField() {
    _fields.first.focusNode.requestFocus();
  }
}
