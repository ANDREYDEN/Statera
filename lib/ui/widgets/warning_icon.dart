import 'package:flutter/material.dart';

class WarningIcon extends StatelessWidget {
  const WarningIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
        child: Icon(
          Icons.warning_amber_rounded,
          size: 20,
        ),
      ),
    );
  }
}
