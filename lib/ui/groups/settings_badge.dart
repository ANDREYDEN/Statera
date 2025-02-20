import 'package:flutter/material.dart';
import 'package:statera/ui/authentication/user_builder.dart';

class SettingsBadge extends StatelessWidget {
  final Widget child;

  const SettingsBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UserBuilder(builder: (context, user) {
      if (user.incompletedProfileParts.isEmpty) {
        return child;
      }

      return Badge.count(
        child: child,
        count: user.incompletedProfileParts.length,
      );
    });
  }
}
