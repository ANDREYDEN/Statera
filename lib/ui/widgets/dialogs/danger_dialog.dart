import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';
import 'package:statera/ui/widgets/buttons/protected_button.dart';

class DangerDialog extends StatefulWidget {
  final String title;
  final String valueName;
  final String value;
  final FutureOr<void> Function() onConfirm;

  const DangerDialog({
    Key? key,
    required this.title,
    required this.valueName,
    required this.value,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<DangerDialog> createState() => _DangerDialogState();
}

class _DangerDialogState extends State<DangerDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _confirmed = false;

  bool get isWide => context.read<LayoutState>().isWide;

  @override
  void initState() {
    _confirmController.addListener(() {
      if (_confirmed ^ (_confirmController.text == widget.value)) {
        setState(() {
          _confirmed = _confirmController.text == widget.value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: isWide ? 400 : 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter the ${widget.valueName} to confirm'),
            TextField(
              controller: _confirmController,
            ),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        ProtectedButton(
          onPressed: _confirmed
              ? () async {
                  await widget.onConfirm();
                  Navigator.pop(context, true);
                }
              : null,
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
