import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/settings/profile_completion/profile_part_list_item.dart';
import 'package:statera/ui/widgets/progress_bar.dart';

class ProfileCompletion extends StatelessWidget {
  final CustomUser user;

  const ProfileCompletion({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'Profile Completion',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${user.completionPercentage}%',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        ProgressBar.progress(
                          progress: user.completionPercentage,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        ...user.incompletedProfileParts
                            .map((part) =>
                                ProfilePartListItem(profilePart: part))
                            .toList(),
                        ...user.completedProfileParts
                            .map((part) =>
                                ProfilePartListItem(profilePart: part))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
