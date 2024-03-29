import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/widgets/buttons/ok_button.dart';
import 'package:statera/ui/widgets/dialogs/dialog_width.dart';

class GreetingDialog extends StatefulWidget {
  final String message;

  const GreetingDialog({Key? key, required this.message}) : super(key: key);

  @override
  State<GreetingDialog> createState() => _GreetingDialogState();
}

class _GreetingDialogState extends State<GreetingDialog> {
  bool _nextTimeGone = false;

  Future<void> _handleConfirm() async {
    final prefecesService = context.read<PreferencesService>();
    await prefecesService.recordGreetingMessageSeen(widget.message);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome back!'),
      content: DialogWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.message),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text("Don't show this again"),
              value: _nextTimeGone,
              onChanged: (_) {
                setState(() {
                  _nextTimeGone = !_nextTimeGone;
                });
              },
            ),
          ],
        ),
      ),
      actions: [OkButton(onPressed: _handleConfirm)],
    );
  }
}
