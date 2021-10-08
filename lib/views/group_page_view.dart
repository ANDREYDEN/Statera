import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/models/author.dart';
import 'package:statera/models/expense.dart';
import 'package:statera/models/group.dart';
import 'package:statera/providers/group_provider.dart';
import 'package:statera/services/firestore.dart';
import 'package:statera/viewModels/authentication_vm.dart';
import 'package:statera/viewModels/group_vm.dart';
import 'package:statera/views/expense_list.dart';
import 'package:statera/views/expense_page.dart';
import 'package:statera/views/group_home.dart';
import 'package:statera/widgets/dialogs/crud_dialog.dart';
import 'package:statera/widgets/page_scaffold.dart';
import 'package:statera/widgets/unmarked_expenses_badge.dart';

class GroupPageView extends StatefulWidget {
  const GroupPageView({Key? key}) : super(key: key);

  @override
  _GroupPageViewState createState() => _GroupPageViewState();
}

class _GroupPageViewState extends State<GroupPageView> {
  int _selectedNavBarItemIndex = 0;
  PageController _pageController = PageController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  Group get group => Provider.of<GroupViewModel>(context, listen: false).group;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: group.name,
      onFabPressed: _selectedNavBarItemIndex == 0 ? null : handleCreateExpense,
      bottomNavBar: BottomNavigationBar(
        iconSize: 36,
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Expenses",
            icon: UnmarkedExpensesBadge(
              groupId: group.id,
              child: Icon(Icons.attach_money),
            ),
            activeIcon: Icon(Icons.attach_money),
          ),
        ],
        currentIndex: this._selectedNavBarItemIndex,
        onTap: (index) {
          setState(() {
            this._selectedNavBarItemIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
      ),
      child: GroupProvider(
        group: group,
        child: PageView(
          controller: this._pageController,
          onPageChanged: (index) {
            setState(() {
              this._selectedNavBarItemIndex = index;
            });
          },
          children: [GroupHome(), ExpenseList()],
        ),
      ),
    );
  }

  void handleCreateExpense() {
    showDialog(
      context: context,
      builder: (context) => CRUDDialog(
        title: "New Expense",
        fields: [
          FieldData(
            id: "expense_name",
            label: "Expense Name",
            validators: [FieldData.requiredValidator],
          )
        ],
        closeAfterSubmit: false,
        onSubmit: (values) async {
          var newExpense = Expense(
            author: Author.fromUser(this.authVm.user),
            name: values["expense_name"]!,
            groupId: this.group.id,
          );
          final expenseId = await Firestore.instance.addExpenseToGroup(
            newExpense,
            this.group.code,
          );
          Navigator.of(context)
              .popAndPushNamed('${ExpensePage.route}/$expenseId');
        },
      ),
    );
  }
}
