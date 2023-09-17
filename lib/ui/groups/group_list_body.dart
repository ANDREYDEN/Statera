import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/groups/group_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class GroupListBody extends StatelessWidget {
  const GroupListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return Center(
        child: Text('Main app functionality is currently in development...'),
      );
    }

    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, groupsState) {
        if (groupsState is GroupsLoading) {
          return Center(child: Loader());
        }

        if (groupsState is GroupsError) {
          developer.log(
            'Failed loading groups',
            error: groupsState.error,
          );

          return Center(child: Text(groupsState.error.toString()));
        }

        if (groupsState is GroupsLoaded) {
          final groups = groupsState.groups;

          return Padding(
            padding: isWide ? kWideMargin : kMobileMargin,
            child: Column(
              children: [
                SizedBox.square(
                  dimension: 16,
                  child: Visibility(
                    visible: groupsState is GroupsProcessing,
                    child: Loader(),
                  ),
                ),
                Expanded(
                  child: groups.isEmpty
                      ? ListEmpty(text: 'Join or create a group!')
                      : GridView.count(
                          crossAxisCount: isWide ? 3 : 1,
                          childAspectRatio: 6,
                          children: groups
                              .map((group) => GroupListItem(group: group))
                              .toList(),
                        ),
                ),
              ],
            ),
          );
        }

        return Container();
      },
    );
  }
}
