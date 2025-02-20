import 'package:flutter/material.dart';
import 'package:statera/data/value_objects/profile_part.dart';

class ProfilePartListItem extends StatelessWidget {
  final ProfilePart profilePart;

  const ProfilePartListItem({super.key, required this.profilePart});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        profilePart.name,
        style: profilePart.isCompleted
            ? Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle:
          profilePart.isCompleted ? null : Text(profilePart.incompleteMessage),
      leading: Icon(
        profilePart.isCompleted
            ? Icons.check_circle_rounded
            : Icons.circle_outlined,
      ),
      titleAlignment: ListTileTitleAlignment.top,
      dense: profilePart.isCompleted,
    );
  }
}
