import 'package:flutter/material.dart';

class SettingInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final void Function(String value) onPressed;

  const SettingInput({
    Key? key,
    required this.initialValue,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  State<SettingInput> createState() => _SettingInputState();
}

class _SettingInputState extends State<SettingInput> {
  late String _newValue;

  @override
  void initState() {
    _newValue = widget.initialValue;
    super.initState();
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
            ),
            onChanged: (value) => setState(() {
              _newValue = value;
            }),
          ),
        ),
        if (_newValue != widget.initialValue) ...[
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
