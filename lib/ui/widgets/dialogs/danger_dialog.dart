import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';

class DangerDialog extends StatefulWidget {
  final String title;
  final Widget? body;
  final String valueName;
  final String value;
  final FutureOr<void> Function() onConfirm;

  const DangerDialog({
    Key? key,
    required this.title,
    required this.valueName,
    required this.value,
    required this.onConfirm,
    this.body,
  }) : super(key: key);

  @override
  State<DangerDialog> createState() => _DangerDialogState();
}

class _DangerDialogState extends State<DangerDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    _confirmController.addListener(() {
      var valueEnteredCorrectly = _confirmController.text == widget.value;
      if (_confirmed ^ valueEnteredCorrectly) {
        setState(() {
          _confirmed = valueEnteredCorrectly;
        });
      }
    });
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
            if (widget.body != null) ...[
              Flexible(child: SingleChildScrollView(child: widget.body!)),
              SizedBox(height: 5),
              Divider(),
            ],
            Text('Please enter the ${widget.valueName} to confirm'),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        ProtectedButton(
          onPressed: _confirmed
              ? () async {
                  try {
                    await widget.onConfirm();
                  } finally {
                    Navigator.pop(context, true);
                  }
                }
              : null,
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
