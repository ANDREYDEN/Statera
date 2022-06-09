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
    return Container(
      width: 50,
      child: ListView(
        children: [
          for (var i = 0; i < items.length; i++)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onItemSelected(i),
                  icon: items[i].wrapper(
                    Icon(
                      i == selectedItem ? items[i].activeIcon : items[i].icon,
                      color:
                          i == selectedItem ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  items[i].label,
                  style: TextStyle(
                      color:
                          i == selectedItem ? Colors.black : Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
