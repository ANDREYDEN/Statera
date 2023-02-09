import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const DangerButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
      child: Text(
        text,
        style: DefaultTextStyle.of(context).style.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
      ),
      onPressed: onPressed,
    );
  }
}
