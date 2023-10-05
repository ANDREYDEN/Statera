import 'package:flutter/material.dart';

class OkButton extends StatelessWidget {
  final dynamic Function()? onPressed;

  const OkButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text('OK'),
    );
  }
}
