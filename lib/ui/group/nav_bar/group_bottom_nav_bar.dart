import 'package:flutter/material.dart';
import 'package:statera/ui/group/nav_bar/nav_bar_item_data.dart';

class GroupBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItemData> items;

  const GroupBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  BottomNavigationBar build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 36,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              label: item.label,
              icon: item.wrapper(Icon(item.icon)),
              activeIcon: item.wrapper(Icon(item.activeIcon)),
            ),
          )
          .toList(),
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
