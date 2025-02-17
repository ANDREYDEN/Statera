import 'package:flutter/material.dart';
import 'package:statera/data/value_objects/profile_part.dart';

class ProfilePartListItem extends StatelessWidget {
  final ProfilePart profilePart;

  const ProfilePartListItem({super.key, required this.profilePart});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(profilePart.name),
      subtitle:
          profilePart.isCompleted ? null : Text(profilePart.incompleteMessage),
      leading: Icon(
        profilePart.isCompleted
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
      ),
      titleAlignment: ListTileTitleAlignment.top,
    );
  }
}
