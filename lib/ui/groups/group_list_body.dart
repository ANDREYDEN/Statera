import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/groups/groups_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/groups/group_list_item/group_list_item.dart';
import 'package:statera/ui/widgets/list_empty.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/utils/utils.dart';

class GroupListBody extends StatefulWidget {
  const GroupListBody({super.key});

  @override
  State<GroupListBody> createState() => _GroupListBodyState();
}

class _GroupListBodyState extends State<GroupListBody> {
  Set<String> _selectedGroupType = {'active'};

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
          groups.sort((userGroup1, userGroup2) {
            if (userGroup1.pinned && userGroup2.pinned) return 0;
            return userGroup1.pinned ? -1 : 1;
          });

          final columnCount = isWide ? 3 : 1;
          final columnWidth = MediaQuery.of(context).size.width / columnCount;

          final archivedGroups = groups.where((group) => group.archived);
          final activeGroups = groups.where((group) => !group.archived);

          final isActive = _selectedGroupType.contains('active');
          final targetGroups = isActive ? activeGroups : archivedGroups;

          return Padding(
            padding: isWide ? kWideMargin : kMobileMargin,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 4,
                  child: Visibility(
                    visible: groupsState is GroupsProcessing,
                    child: LinearProgressIndicator(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: 'active',
                        label: Text('Active'),
                        icon: Icon(Icons.groups),
                      ),
                      ButtonSegment(
                        value: 'archived',
                        label: Text('Archived'),
                        icon: Icon(Icons.archive),
                      )
                    ],
                    selected: _selectedGroupType,
                    onSelectionChanged: (newSelectedGroupType) => setState(() {
                      _selectedGroupType = newSelectedGroupType;
                    }),
                  ),
                ),
                Expanded(
                  child: targetGroups.isEmpty
                      ? ListEmpty(
                          text: isActive
                              ? 'Join or create a group!'
                              : 'You have not archived any groups yet')
                      : GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: columnCount,
                          childAspectRatio: columnWidth / 110,
                          children: [
                            ...targetGroups
                                .map((group) => GroupListItem(userGroup: group))
                                .toList(),
                            SizedBox(height: 100), // leave space for FAB
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
