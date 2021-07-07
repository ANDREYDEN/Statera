import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/services/auth.dart';
import 'package:statera/viewModels/group_vm.dart';
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

  GroupViewModel get groupVm => Provider.of<GroupViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: groupVm.group.name,
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
