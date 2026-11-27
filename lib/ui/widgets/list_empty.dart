import 'package:flutter/material.dart';
import 'package:statera/ui/styling/index.dart';

class ListEmpty extends StatelessWidget {
  final String text;
  final Icon? icon;
  final List<Widget> actions;
  final Axis direction;

  const ListEmpty({
    Key? key,
    required this.text,
    this.icon,
    this.actions = const [],
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      direction: this.direction,
      children: [
        if (this.actions.isNotEmpty && this.direction == Axis.horizontal)
          Padding(
            padding: const EdgeInsets.only(right: Spacing.m_10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions
                  .expand((a) => [a, SizedBox(width: 5)])
                  .take(2 * actions.length - 1)
                  .toList(),
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              this.text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge!.copyWith(color: Colors.grey[400]),
            ),
          ),
        ),
        if (this.icon != null) this.icon!,
        if (this.actions.isNotEmpty && this.direction == Axis.vertical)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.s_8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions
                  .expand((a) => [a, SizedBox(width: 5)])
                  .take(2 * actions.length - 1)
                  .toList(),
            ),
          ),
      ],
    );
  }
}
