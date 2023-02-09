import 'package:flutter/material.dart';
import 'package:statera/ui/group/nav_bar/nav_bar_item_data.dart';

class GroupSideNavBar extends StatelessWidget {
  final int selectedItem;
  final Function(int) onItemSelected;
  final List<NavBarItemData> items;

  const GroupSideNavBar({
    Key? key,
    required this.onItemSelected,
    required this.selectedItem,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      destinations: items
          .map((item) => NavigationRailDestination(
                icon: item.wrapper(Icon(item.icon)),
                label: item.wrapper(Text(item.label)),
                selectedIcon: Icon(item.activeIcon),
              ))
          .toList(),
      selectedIndex: selectedItem,
      onDestinationSelected: onItemSelected,
    );
  }
}
