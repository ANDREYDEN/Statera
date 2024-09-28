import 'package:flutter/material.dart';

class CollapsibleHeader extends StatelessWidget {
  final bool isCollapsed;
  final String title;
  final TextStyle? titleTextStyle;
  final Function() onTap;

  const CollapsibleHeader({
    super.key,
    required this.title,
    this.titleTextStyle,
    required this.onTap,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                title,
                style: titleTextStyle,
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
    );
  }
}
