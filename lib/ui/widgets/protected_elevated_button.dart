import 'dart:async';

import 'package:flutter/material.dart';

class ProtectedElevatedButton extends StatefulWidget {
  final Function onPressed;

  final Widget child;

  const ProtectedElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  _ProtectedElevatedButtonState createState() =>
      _ProtectedElevatedButtonState();
}

class _ProtectedElevatedButtonState extends State<ProtectedElevatedButton> {
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
        return ElevatedButton(
          onPressed: actionInProgress
              ? null
              : () async {
                  _actionStateController.add(true);
                  await widget.onPressed();
                },
          child: widget.child,
        );
      },
    );
  }
}
