import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';

class SettingInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final void Function(String value) onPressed;
  final List<Validator>? validators;
  final List<TextInputFormatter>? formatters;
  final String? helperText;

  const SettingInput({
    Key? key,
    required this.initialValue,
    required this.onPressed,
    required this.label,
    this.validators,
    this.formatters,
    this.helperText,
  }) : super(key: key);

  @override
  State<SettingInput> createState() => _SettingInputState();
}

class _SettingInputState extends State<SettingInput> {
  late String _newValue;
  String? _error;

  @override
  void initState() {
    _newValue = widget.initialValue;
    super.initState();
  }

  String? _getError() {
    for (final validator in widget.validators ?? []) {
      var error = validator(_newValue);
      if (error.isNotEmpty) return error;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: widget.initialValue,
              decoration: InputDecoration(
                label: Text(widget.label),
                errorText: _error,
                helperText: widget.helperText,
              ),
              inputFormatters: widget.formatters,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                  _error = _getError();
                });
              },
              onFieldSubmitted: (_) => widget.onPressed(_newValue),
            ),
          ),
          if (_newValue != widget.initialValue && _error == null) ...[
            SizedBox(width: 4),
            IconButton.filledTonal(
              icon: Icon(Icons.check_rounded),
              color: Colors.green,
              onPressed: () => widget.onPressed(_newValue),
            )
          ]
        ],
      ),
    );
  }
}
