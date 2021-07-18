import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/home.dart';
import 'package:statera/widgets/page_scaffold.dart';
import 'package:statera/widgets/unmarked_expenses_badge.dart';

class GroupPage extends StatefulWidget {
  static const String route = "group";

  const GroupPage({Key? key}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int selectedNavBarItemIndex = 0;
  PageController pageController = PageController();

  GroupViewModel get groupVm =>
      Provider.of<GroupViewModel>(context, listen: false);

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: groupVm.group.name,
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
            icon: UnmarkedExpensesBadge(child: Icon(Icons.attach_money)),
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
      child: PageView(
        controller: this.pageController,
        onPageChanged: (index) {
          setState(() {
            this.selectedNavBarItemIndex = index;
          });
        },
        children: [Home(), ExpenseList()],
      ),
    );
  }
}
