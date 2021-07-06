import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/widgets/page_scaffold.dart';

class GroupScaffoldItem {
  IconData icon;
  String label;
  Widget view;

  GroupScaffoldItem({
    required this.icon,
    required this.label,
    required this.view,
  });
}

class GroupScaffold extends StatefulWidget {
  final List<GroupScaffoldItem> items;

  const GroupScaffold({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  _GroupScaffoldState createState() => _GroupScaffoldState();
}

class _GroupScaffoldState extends State<GroupScaffold> {
  int selectedNavBarItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Statera",
      bottomNavBar: BottomNavigationBar(
        iconSize: 36,
        items: widget.items
            .map((item) => BottomNavigationBarItem(
                  label: item.label,
                  icon: Icon(item.icon),
                  activeIcon: Icon(
                    item.icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ))
            .toList(),
        currentIndex: this.selectedNavBarItemIndex,
        onTap: (index) {
          setState(() {
            this.selectedNavBarItemIndex = index;
          });
        },
      ),
      child: widget.items[this.selectedNavBarItemIndex].view,
    );
  }
}
