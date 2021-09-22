import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/group.dart';
import 'package:statera/providers/group_provider.dart';
import 'package:statera/services/firestore.dart';

import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/group_home.dart';
import 'package:statera/widgets/page_scaffold.dart';
import 'package:statera/widgets/unmarked_expenses_badge.dart';

class GroupPage extends StatefulWidget {
  static const String route = "/group";
  final String? groupId;

  const GroupPage({Key? key, this.groupId}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int selectedNavBarItemIndex = 0;
  PageController pageController = PageController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Group>(
      stream: Firestore.instance.groupStream(widget.groupId),
      builder: (context, snap) {
        if (snap.hasError) {
          return PageScaffold(child: Text(snap.error.toString()));
        }
        if (!snap.hasData || snap.connectionState == ConnectionState.waiting) {
          return PageScaffold(
              child: Center(child: CircularProgressIndicator()));
        }

        final Group group = snap.data!;

        return PageScaffold(
          title: group.name,
          bottomNavBar: BottomNavigationBar(
            iconSize: 36,
            items: [
              BottomNavigationBarItem(
                label: "Home",
                icon: Icon(Icons.home),
                activeIcon: Icon(
                  Icons.home,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              BottomNavigationBarItem(
                label: "Expenses",
                icon: UnmarkedExpensesBadge(
                  groupId: group.id,
                  child: Icon(Icons.attach_money),
                ),
                activeIcon: Icon(
                  Icons.attach_money,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
            currentIndex: this.selectedNavBarItemIndex,
            onTap: (index) {
              setState(() {
                this.selectedNavBarItemIndex = index;
              });
              pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
          child: GroupProvider(
            group: group,
            child: PageView(
              controller: this.pageController,
              onPageChanged: (index) {
                setState(() {
                  this.selectedNavBarItemIndex = index;
                });
              },
              children: [GroupHome(), ExpenseList()],
            ),
          ),
        );
      },
    );
  }
}
