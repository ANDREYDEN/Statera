import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final String title;
  final Widget child;

  const Collapsible({
    Key? key,
    required this.title,
    required this.child,
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isCollapsed = !isCollapsed;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(widget.title),
                  Icon(
                    isCollapsed ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isCollapsed) widget.child
      ],
    );
  }
}
