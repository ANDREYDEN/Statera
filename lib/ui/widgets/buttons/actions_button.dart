import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/entity_action.dart';

class ActionsButton extends StatelessWidget {
  final List<EntityAction> actions;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const ActionsButton({
    super.key,
    required this.actions,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: PopupMenuButton<EntityAction>(
        tooltip: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(Icons.more_vert),
        ),
        itemBuilder: (context) => actions.map((action) {
          return PopupMenuItem(
            value: action,
            child: Row(
              children: [
                Icon(action.icon, color: action.getIconColor(context)),
                SizedBox(width: 4),
                Flexible(child: Text(action.name)),
              ],
            ),
          );
        }).toList(),
        onSelected: (action) => action.safeHandle(context),
      ),
    );
  }
}
