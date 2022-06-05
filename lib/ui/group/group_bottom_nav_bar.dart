import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GroupBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  BottomNavigationBar build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 36,
      items: [
        BottomNavigationBarItem(
          label: "Home",
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
        ),
        BottomNavigationBarItem(
          label: "Expenses",
          icon: UnmarkedExpensesBadge(child: Icon(Icons.receipt_long_outlined)),
          activeIcon: Icon(Icons.receipt_long),
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
