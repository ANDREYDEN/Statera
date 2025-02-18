import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/settings/profile_completion/profile_part_list_item.dart';

class ProfileCompletion extends StatelessWidget {
  final CustomUser user;

  const ProfileCompletion({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profile Completion',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${user.completionPercentage}%',
                      style: isWide
                          ? Theme.of(context).textTheme.displayLarge
                          : Theme.of(context).textTheme.displaySmall,
                    ),
                    LinearProgressIndicator(
                      value: user.completionPercentage / 100,
                      borderRadius: BorderRadius.circular(100),
                      minHeight: 10,
                    )
                  ],
                ),
              ),
              SizedBox.square(dimension: 10),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...user.incompletedProfileParts
                        .map((part) => ProfilePartListItem(profilePart: part))
                        .toList(),
                    ...user.completedProfileParts
                        .map((part) => ProfilePartListItem(profilePart: part))
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
