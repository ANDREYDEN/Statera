import 'package:flutter/material.dart';

class ListEmpty extends StatelessWidget {
  final String text;
  final Icon? icon;
  final List<Widget> actions;

  const ListEmpty({
    Key? key,
    required this.text,
    this.icon,
    this.actions = const [],
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
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ),
        ),
        if (this.icon != null) this.icon!,
        if (this.actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .expand((a) => [a, SizedBox(width: 5)])
                    .take(2 * actions.length - 1)
                    .toList()),
          )
      ],
    );
  }
}
