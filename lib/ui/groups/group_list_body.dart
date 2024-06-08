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

          final columnCount = isWide ? 3 : 1;
          final columnWidth = MediaQuery.of(context).size.width / columnCount;

          return Padding(
            padding: isWide ? kWideMargin : kMobileMargin,
            child: Column(
              children: [
                SizedBox(
                  height: 4,
                  child: Visibility(
                    visible: groupsState is GroupsProcessing,
                    child: LinearProgressIndicator(),
                  ),
                ),
                Expanded(
                  child: groups.isEmpty
                      ? ListEmpty(text: 'Join or create a group!')
                      : GridView.count(
                          crossAxisCount: columnCount,
                          childAspectRatio: columnWidth / 100,
                          children: [
                            ...groups
                                .map((group) => GroupListItem(userGroup: group))
                                .toList(),
                            SizedBox(height: 100) // leave space for FAB
                          ],
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
