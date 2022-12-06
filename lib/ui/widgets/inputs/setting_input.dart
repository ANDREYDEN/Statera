import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog/crud_dialog.dart';

class SettingInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final void Function(String value) onPressed;
  final List<Validator>? validators;
  final List<TextInputFormatter>? formatters;

  const SettingInput({
    Key? key,
    required this.initialValue,
    required this.onPressed,
    required this.label,
    this.validators,
    this.formatters,
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
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: widget.initialValue,
            decoration: InputDecoration(
              label: Text(widget.label),
              errorText: _error,
            ),
            inputFormatters: widget.formatters,
            onChanged: (value) {
              setState(() {
                _newValue = value;
                _error = _getError();
              });
            },
          ),
        ),
        if (_newValue != widget.initialValue && _error == null) ...[
          SizedBox(width: 4),
          ElevatedButton(
            child: Icon(Icons.check_rounded),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: Colors.green,
              padding: EdgeInsets.all(0),
            ),
            onPressed: () => widget.onPressed(_newValue),
          )
        ]
      ],
    );
  }
}
