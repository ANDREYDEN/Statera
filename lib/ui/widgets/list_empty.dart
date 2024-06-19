import 'package:flutter/material.dart';

class ListEmpty extends StatelessWidget {
  final String text;
  final Icon? icon;
  final Widget? action;

  const ListEmpty({
    Key? key,
    required this.text,
    this.icon,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              this.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 24,
              ),
            ),
          ),
        ),
        if (this.icon != null) this.icon!,
        if (this.action != null) this.action!,
      ],
    );
  }
}
