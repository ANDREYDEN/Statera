import 'package:flutter/material.dart';

class CancelButton<T> extends StatelessWidget {
  final dynamic Function()? onPressed;
  final T? returnValue;

  const CancelButton({
    Key? key,
    this.onPressed,
    this.returnValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          onPressed ?? () => Navigator.pop(context, returnValue),
      child: Text(
        'Cancel',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
