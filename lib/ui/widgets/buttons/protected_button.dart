import 'dart:async';

import 'package:flutter/material.dart';

enum ButtonType { elevated, text }

class ProtectedButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final ButtonType buttonType;

  final Widget child;

  const ProtectedButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.buttonType = ButtonType.elevated,
  }) : super(key: key);

  @override
  _ProtectedButtonState createState() => _ProtectedButtonState();
}

class _ProtectedButtonState extends State<ProtectedButton> {
  final _actionStateController = StreamController();

  @override
  initState() {
    _actionStateController.add(false);
    super.initState();
  }

  @override
  void dispose() {
    _actionStateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _actionStateController.stream,
      builder: (context, snapshot) {
        final actionInProgress = !snapshot.hasData || snapshot.data == true;
        var onPressed = actionInProgress || widget.onPressed == null
            ? null
            : () async {
                _actionStateController.add(true);
                await widget.onPressed!();
                _actionStateController.add(false);
              };

        final content = actionInProgress
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : widget.child;
        return widget.buttonType == ButtonType.text
            ? TextButton(onPressed: onPressed, child: content)
            : ElevatedButton(onPressed: onPressed, child: content);
      },
    );
  }
}
