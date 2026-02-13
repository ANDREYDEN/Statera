import 'package:flutter/material.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/styling/border_rad.dart';

class InfoMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;

  const InfoMessage({super.key, required this.message, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.xs_5),
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRad.s_10,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(width: Spacing.m_10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
