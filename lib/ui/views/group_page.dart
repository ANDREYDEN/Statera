import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statera/data/models/author.dart';
import 'package:statera/data/models/expense.dart';
import 'package:statera/data/models/group.dart';
import 'package:statera/data/services/firestore.dart';
import 'package:statera/data/states/group_state.dart';
import 'package:statera/ui/viewModels/authentication_vm.dart';
import 'package:statera/ui/views/expense_list.dart';
import 'package:statera/ui/views/expense_page.dart';
import 'package:statera/ui/views/group_home.dart';
import 'package:statera/ui/widgets/dialogs/crud_dialog.dart';
import 'package:statera/ui/widgets/loader.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';
import 'package:statera/ui/widgets/unmarked_expenses_badge.dart';

class GroupPage extends StatefulWidget {
  static const String route = "/group";
  final String? groupId;

  const GroupPage({Key? key, this.groupId}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _selectedNavBarItemIndex = 0;
  PageController _pageController = PageController();

  AuthenticationViewModel get authVm =>
      Provider.of<AuthenticationViewModel>(context, listen: false);

  Widget build(BuildContext context) {
    return StreamProvider<GroupState>.value(
      initialData: GroupLoadingState(),
      catchError: (context, error) => GroupErrorState(error),
      value: Firestore.instance
          .groupStream(this.widget.groupId)
          .map((group) => GroupState(group: group)),
      builder: (context, _) {
        return Consumer<GroupState>(
          builder: (context, groupState, _) {
            if (groupState.isLoading) {
              return PageScaffold(child: Center(child: Loader()));
            }

            if (groupState.hasError) {
              return PageScaffold(child: Text(groupState.error.toString()));
            }

            return PageScaffold(
              title: groupState.group.name,
              onFabPressed: _selectedNavBarItemIndex == 0
                  ? null
                  : () => handleCreateExpense(groupState.group),
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
                      groupId: groupState.group.id,
                      child: Icon(Icons.receipt_long),
                    ),
                    activeIcon: Icon(Icons.receipt_long),
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
              child: PageView(
                controller: this._pageController,
                onPageChanged: (index) {
                  setState(() {
                    this._selectedNavBarItemIndex = index;
                  });
                },
                children: [GroupHome(), ExpenseList()],
              ),
            );
          },
        );
      },
    );
  }

  void handleCreateExpense(Group group) {
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
            groupId: group.id,
          );
          final expenseId = await Firestore.instance.addExpenseToGroup(
            newExpense,
            group.code,
          );
          Navigator.of(context)
              .popAndPushNamed('${ExpensePage.route}/$expenseId');
        },
      ),
    );
  }
}
