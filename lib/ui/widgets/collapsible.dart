import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/collapsible_header.dart';

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
        CollapsibleHeader(
          title: widget.title,
          titleTextStyle: widget.titleTextStyle,
          onTap: () {
            setState(() {
              isCollapsed = !isCollapsed;
            });
          },
          isCollapsed: isCollapsed,
        ),
        if (!isCollapsed) Flexible(child: widget.child)
      ],
    );
  }
}
