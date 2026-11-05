import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/ui/groups/group_list_item/group_list_item.dart';
import 'package:statera/ui/groups/group_list_item/group_list_item_loading.dart';
import 'package:statera/ui/groups/groups_builder.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/list_empty.dart';
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
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
      return Center(
        child: Text('Main app functionality is currently in development...'),
      );
    }

    final isWide = context.select((LayoutState state) => state.isWide);

    final columnCount = isWide ? 3 : 1;
    final columnWidth = MediaQuery.of(context).size.width / columnCount;
    final rowHeight = 110;
    final itemAspectRatio = clampDouble(columnWidth / rowHeight, 2, 6);

    return GroupsBuilder(
      builder: (context, groups, isLoading, isProcessing) {
        groups.sort((userGroup1, userGroup2) {
          if (userGroup1.pinned && userGroup2.pinned) return 0;
          return userGroup1.pinned ? -1 : 1;
        });

        final archivedGroups = groups.where((group) => group.archived);
        final activeGroups = groups.where((group) => !group.archived);

        final isActive = _selectedGroupType.contains('active');
        final targetGroups = isActive ? activeGroups : archivedGroups;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 4,
              child: Visibility(
                visible: isProcessing,
                child: LinearProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.m_10),
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
                  ),
                ],
                selected: _selectedGroupType,
                onSelectionChanged: isLoading
                    ? null
                    : (Set<String> newSelectedGroupType) => setState(() {
                        _selectedGroupType = newSelectedGroupType;
                      }),
              ),
            ),
            Expanded(
              child: !isLoading && targetGroups.isEmpty
                  ? ListEmpty(
                      text: isActive
                          ? 'Join or create a group!'
                          : 'You have not archived any groups yet',
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: columnCount,
                      childAspectRatio: itemAspectRatio,
                      children: [
                        if (isLoading)
                          ...List.filled(
                            5,
                            GroupListItemLoading(height: rowHeight * 1.0),
                          )
                        else
                          ...targetGroups
                              .map((group) => GroupListItem(userGroup: group))
                              .toList(),
                        SizedBox(height: 100), // leave space for FAB
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
