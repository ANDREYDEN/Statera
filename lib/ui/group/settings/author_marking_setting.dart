import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/data/models/models.dart';

class AuthorMarkingSetting extends StatelessWidget {
  final Group group;

  const AuthorMarkingSetting({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        'Allow expense authors to mark items on behalf of other assignees',
      ),
      value: group.allowAuthorsToMarkOnBehalfOfOthers,
      onChanged: (isOn) {
        final groupCubit = context.read<GroupCubit>();

        groupCubit.update((group) {
          group.allowAuthorsToMarkOnBehalfOfOthers = isOn;
        });
      },
    );
  }
}
