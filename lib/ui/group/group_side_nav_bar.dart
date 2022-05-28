import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupSideNavBar extends StatelessWidget {
  final Function(int) onItemSelected;

  const GroupSideNavBar({Key? key, required this.onItemSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: ListView(
        children: [
          IconButton(
            onPressed: () => onItemSelected(0),
            icon: Icon(Icons.home_rounded),
          ),
          IconButton(
            onPressed: () => onItemSelected(1),
            icon:
                UnmarkedExpensesBadge(child: Icon(Icons.receipt_long_rounded)),
          ),
        ],
      ),
    );
  }
}
