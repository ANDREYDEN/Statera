import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final dynamic Function()? onPressed;

  const CancelButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context, false),
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      ),
    );
  }
}
