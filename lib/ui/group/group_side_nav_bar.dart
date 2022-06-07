import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupSideNavBar extends StatelessWidget {
  final int selectedItem;
  final Function(int) onItemSelected;

  const GroupSideNavBar({
    Key? key,
    required this.onItemSelected,
    required this.selectedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: ListView(
        children: [
          IconButton(
            onPressed: () => onItemSelected(0),
            icon: Icon(
              selectedItem == 0 ? Icons.group_rounded : Icons.group_outlined,
            ),
          ),
          IconButton(
            onPressed: () => onItemSelected(1),
            icon: UnmarkedExpensesBadge(
              child: Icon(selectedItem == 1
                  ? Icons.receipt_long_rounded
                  : Icons.receipt_long_outlined),
            ),
          ),
          IconButton(
            onPressed: () => onItemSelected(2),
            icon: Icon(
              selectedItem == 2
                  ? Icons.settings_rounded
                  : Icons.settings_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
