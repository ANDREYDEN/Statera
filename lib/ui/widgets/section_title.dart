import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final String? tooltipText;

  const SectionTitle(
    this.text, {
    this.alignment = Alignment.center,
    this.tooltipText,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: Theme.of(context).textTheme.titleLarge),
          if (tooltipText != null) ...[
            SizedBox(width: 10),
            Tooltip(message: tooltipText, child: Icon(Icons.info, size: 20)),
          ]
        ],
      ),
    );
  }
}
