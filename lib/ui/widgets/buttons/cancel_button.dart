import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final dynamic Function()? onPressed;
  final bool returnsNull;

  const CancelButton({
    Key? key,
    this.onPressed,
    this.returnsNull = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          onPressed ?? () => Navigator.pop(context, returnsNull ? null : false),
      child: Text(
        'Cancel',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
