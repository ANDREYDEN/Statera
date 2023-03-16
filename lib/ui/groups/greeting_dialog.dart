import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingDialog extends StatefulWidget {
  final String message;

  const GreetingDialog({Key? key, required this.message}) : super(key: key);

  @override
  State<GreetingDialog> createState() => _GreetingDialogState();
}

class _GreetingDialogState extends State<GreetingDialog> {
  bool _nextTimeGone = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome back!'),
      content: Text(widget.message),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: CheckboxListTile(
                title: Text("Don't show this again"),
                value: _nextTimeGone,
                onChanged: (_) {
                  setState(() {
                    _nextTimeGone = !_nextTimeGone;
                  });
                },
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(
                    widget.message.hashCode.toString(), _nextTimeGone);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ],
    );
  }
}
