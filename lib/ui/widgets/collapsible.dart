import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final String title;
  final TextStyle? titleTextStyle;
  final Widget child;

  const Collapsible({
    Key? key,
    required this.title,
    required this.child,
    this.titleTextStyle,
  }) : super(key: key);

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isCollapsed = !isCollapsed;
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: widget.titleTextStyle,
                  ),
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isCollapsed) Flexible(child: widget.child)
      ],
    );
  }
}
