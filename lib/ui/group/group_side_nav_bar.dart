import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupSideNavBar extends StatelessWidget {
  final int selectedItem;
  final Function(int) onItemSelected;
  final List<Widget Function(bool isActive)> iconBuilders;

  const GroupSideNavBar({
    Key? key,
    required this.onItemSelected,
    required this.selectedItem,
    required this.iconBuilders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: ListView(
        children: [
          for(var i = 0; i < iconBuilders.length; i++)
          IconButton(
            onPressed: () => onItemSelected(i),
            icon: iconBuilders[i](i == selectedItem),
          ),
        ],
      ),
    );
  }
}
