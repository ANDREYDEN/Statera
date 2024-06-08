import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/entity_action.dart';

class ActionsButton extends StatelessWidget {
  final List<EntityAction> actions;

  const ActionsButton({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      child: PopupMenuButton<EntityAction>(
        tooltip: 'Expense actions',
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(Icons.more_vert),
        ),
        itemBuilder: (context) => actions.map((action) {
          return PopupMenuItem(
            value: action,
            child: Row(
              children: [
                Icon(
                  action.icon,
                  color: action.getIconColor(context),
                ),
                SizedBox(width: 4),
                Text(action.name),
              ],
            ),
          );
        }).toList(),
        onSelected: (action) => action.safeHandle(context),
      ),
    );
  }
}
